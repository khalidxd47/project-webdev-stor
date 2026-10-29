<?php

declare(strict_types=1);
/** إعدادات مشتركة وPDO ومعاملات محضرة واستجابات موحدة. */
date_default_timezone_set('UTC');
const ROOT = __DIR__.'/..';
final class HttpError extends RuntimeException
{
    public function __construct(public int $status, string $message)
    {
        parent::__construct($message);
    }
}

function fail(int $s, string $m): never
{
    throw new HttpError($s, $m);
}

function config(): array
{
    static $c;
    if (null === $c) {
        $file = getenv('STOR_CONFIG') ?: ROOT.'/config/config.local.php';
        if (!is_file($file)) {
            fail(503, 'شغّل php scripts/config-init.php ثم اضبط قاعدة البيانات.');
        }
        $c = require $file;
        if (!preg_match('/^[a-f0-9]{64}$/i', $c['encryption_key'] ?? '')) {
            fail(503, 'مفتاح تشفير البريد غير مضبوط.');
        }
    }

    return $c;
}

/** مصادر الطلب المسموحة: origin الرئيسي + allowed_origins (مثل localhost وعناوين Laragon .test). */
function originAllowed(string $origin): bool
{
    $list = array_merge([config()['origin']], config()['allowed_origins'] ?? []);

    return in_array($origin, array_map(fn ($o) => rtrim((string) $o, '/'), $list), true);
}

function db(): PDO
{
    static $pdo;
    if (!$pdo) {
        $c = config()['db'];
        $o = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES => false];
        if (!empty($c['ssl_ca'])) {
            $o[PDO::MYSQL_ATTR_SSL_CA] = $c['ssl_ca'];
            $o[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = true;
        }

        $pdo = new PDO("mysql:host={$c['host']};port={$c['port']};dbname={$c['name']};charset=utf8mb4", $c['user'], $c['password'], $o);
        $pdo->exec("SET time_zone='+00:00'");
    }

    return $pdo;
}

function query(string $s, array $p = []): PDOStatement
{
    $q = db()->prepare($s);
    $q->execute($p);

    return $q;
}

function all(string $s, array $p = []): array
{
    return query($s, $p)->fetchAll();
}

function one(string $s, array $p = []): ?array
{
    return query($s, $p)->fetch() ?: null;
}

function insert(string $s, array $p): int
{
    query($s, $p);

    return (int) db()->lastInsertId();
}

function transaction(callable $f): mixed
{
    db()->beginTransaction();
    try {
        $r = $f();
        db()->commit();

        return $r;
    } catch (Throwable $e) {
        if (db()->inTransaction()) {
            db()->rollBack();
        }
        throw $e;
    }
}

function jsonResponse(mixed $v, int $s = 200): never
{
    http_response_code($s);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($v, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    exit;
}

function e(mixed $s): string
{
    return htmlspecialchars((string) $s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function text(array $d, string $k, int $min = 0, int $max = 255): string
{
    if (!isset($d[$k]) || !is_string($d[$k])) {
        fail(400, "الحقل $k غير صحيح.");
    }

    $s = trim($d[$k]);
    if (mb_strlen($s) < $min || mb_strlen($s) > $max) {
        fail(400, "طول الحقل $k غير صحيح.");
    }

    return $s;
}

function integer(mixed $v, int $min = 1, int $max = 2147483647): int
{
    if (false === filter_var($v, FILTER_VALIDATE_INT) || $v < $min || $v > $max) {
        fail(400, 'رقم غير صحيح.');
    }

    return (int) $v;
}

function emailInput(array $d): string
{
    $v = strtolower(text($d, 'email', 3, 254));
    if (!filter_var($v, FILTER_VALIDATE_EMAIL)) {
        fail(400, 'البريد الإلكتروني غير صحيح.');
    }

    return $v;
}

function passwordInput(array $d): string
{
    $v = $d['password'] ?? null;
    if (!is_string($v) || mb_strlen($v) < 12 || strlen($v) > 128) {
        fail(400, 'كلمة المرور 12 حرفًا على الأقل و128 بايت كحد أقصى.');
    }

    return $v;
}

function passwordHash(string $p): string
{
    return password_hash($p, PASSWORD_ARGON2ID);
}

function token(): string
{
    return bin2hex(random_bytes(32));
}

function digest(string $s): string
{
    return hash('sha256', $s);
}

function secureHeaders(): void
{
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: no-referrer');
    // Google Fonts فقط كمصدر خارجي للخطوط؛ يطابق CSP في public/.htaccess.
    header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; media-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'");
}

function ipHash(): string
{
    return digest(config()['encryption_key'].'|'.($_SERVER['REMOTE_ADDR'] ?? 'cli'));
}

function rateLimit(string $g, int $limit = 10, int $seconds = 900): void
{
    $k = digest($g.'|'.ipHash());
    query('INSERT INTO rate_limits(bucket_hash,hits,expires_at) VALUES (?,1,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL ? SECOND)) ON DUPLICATE KEY UPDATE hits=IF(expires_at<UTC_TIMESTAMP(3),1,hits+1),expires_at=IF(expires_at<UTC_TIMESTAMP(3),VALUES(expires_at),expires_at)', [$k, $seconds]);
    if ((int) one('SELECT hits FROM rate_limits WHERE bucket_hash=?', [$k])['hits'] > $limit) {
        fail(429, 'محاولات كثيرة. حاول لاحقًا.');
    }
}

function sessionInfo(string $portal = 'customer'): ?array
{
    $raw = $_COOKIE['stor_'.$portal] ?? '';
    if (!preg_match('/^[a-f0-9]{64}$/', $raw)) {
        return null;
    }

    $s = one('SELECT s.id AS session_id,s.csrf_token,u.id,u.full_name,u.email,u.username,r.code AS role FROM sessions s JOIN users u ON u.id=s.user_id JOIN roles r ON r.id=u.role_id WHERE s.token_hash=? AND s.portal=? AND r.code=? AND s.expires_at>UTC_TIMESTAMP(3) AND u.is_active=1', [digest($raw), $portal, $portal]);
    if (!$s) {
        return null;
    }

    return ['id' => (int) $s['session_id'], 'csrf' => $s['csrf_token'], 'user' => ['id' => (int) $s['id'], 'name' => $s['full_name'], 'email' => $s['email'], 'username' => $s['username'], 'role' => $s['role']]];
}

function requireSession(string $p = 'customer'): array
{
    $s = sessionInfo($p);
    if (!$s) {
        fail(401, 'سجّل الدخول للمتابعة.');
    }

    if (!in_array($_SERVER['REQUEST_METHOD'] ?? 'GET', ['GET', 'HEAD'], true) && !hash_equals($s['csrf'], $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '')) {
        fail(403, 'رمز حماية الطلب غير صحيح.');
    }

    return $s;
}

function sessionCookie(string $p, string $raw, int $expires): void
{
    setcookie('stor_'.$p, $raw, ['expires' => $expires, 'path' => '/', 'secure' => str_starts_with(config()['origin'], 'https://'), 'httponly' => true, 'samesite' => 'Strict']);
}

function createSession(int $id, string $p): array
{
    $raw = token();
    $csrf = token();
    $days = (int) config()['session_days'];
    query('INSERT INTO sessions(user_id,portal,token_hash,csrf_token,expires_at) VALUES (?,?,?,?,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL ? DAY))', [$id, $p, digest($raw), $csrf, $days]);
    sessionCookie($p, $raw, time() + $days * 86400);

    return ['csrf' => $csrf];
}

function authEvent(?int $id, string $event, bool $ok): void
{
    query('INSERT INTO auth_events(user_id,event_type,succeeded,ip_hash) VALUES (?,?,?,?)', [$id, $event, (int) $ok, ipHash()]);
}

function audit(int $admin, string $action, string $entity, int $id, mixed $before = null, mixed $after = null): void
{
    query('INSERT INTO admin_audit_log(admin_id,action,entity_type,entity_id,before_data,after_data) VALUES (?,?,?,?,?,?)', [$admin, $action, $entity, $id, null === $before ? null : json_encode($before), null === $after ? null : json_encode($after)]);
}
