<?php

/** تسجيل حسابات دائمة، جلسات محمية، وإعادة تعيين أحادية الاستخدام. */
function registerCustomer(array $d): array
{
    rateLimit('register', 8);
    $name = text($d, 'name', 3, 120);
    $email = emailInput($d);
    $hash = passwordHash(passwordInput($d));

    return transaction(function () use ($name, $email, $hash) {
        $id = insert('INSERT INTO users(role_id,full_name,email,password_hash) VALUES (1,?,?,?)', [$name, $email, $hash]);
        query('INSERT INTO customer_profiles(user_id) VALUES (?)', [$id]);
        authEvent($id, 'register', true);

        return ['user' => ['id' => $id, 'name' => $name, 'email' => $email, 'role' => 'customer']] + createSession($id, 'customer');
    }
    );
}

function loginUser(array $d, string $portal): array
{
    rateLimit('login-'.$portal, 10);
    $identifier = strtolower(text($d, 'identifier', 1, 254));
    $password = $d['password'] ?? '';
    if (!is_string($password) || strlen($password) > 128) {
        fail(400, 'بيانات غير صحيحة.');
    }

    $u = one('SELECT u.*,r.code AS role FROM users u JOIN roles r ON r.id=u.role_id WHERE (u.email=? OR u.username=?) AND r.code=?', [$identifier, $identifier, $portal]);
    $dummy = '$argon2id$v=19$m=65536,t=4,p=1$ZG9udHVzZXRoaXNwYXNz$9dUUVD3rNM8u0iC4PnQVMsR6Otq9Zc7YMeWoZs4Mhi8';
    $ok = password_verify($password, $u['password_hash'] ?? $dummy);
    if (!$u || !$u['is_active'] || !$ok) {
        authEvent($u ? (int) $u['id'] : null, $portal.'_login', false);
        fail(401, 'بيانات الدخول غير صحيحة.');
    }

    return transaction(function () use ($u, $portal) {
        $locked = one('SELECT * FROM users WHERE id=? FOR UPDATE', [$u['id']]);
        if (!$locked['is_active'] || $locked['password_hash'] !== $u['password_hash']) {
            fail(401, 'أعد تسجيل الدخول.');
        }

        query('UPDATE users SET last_login_at=UTC_TIMESTAMP(3) WHERE id=?', [$u['id']]);
        authEvent((int) $u['id'], $portal.'_login', true);

        return ['user' => ['id' => (int) $u['id'], 'name' => $u['full_name'], 'email' => $u['email'], 'username' => $u['username'], 'role' => $portal]] + createSession((int) $u['id'], $portal);
    }
    );
}

function forgotPassword(array $d): array
{
    $started = microtime(true);
    rateLimit('forgot-password', 5);
    $email = emailInput($d);
    $portal = $d['portal'] ?? '';
    if (!in_array($portal, ['customer', 'admin'], true)) {
        fail(400, 'نوع الحساب غير صحيح.');
    }
    transaction(function () use ($email, $portal) {
        $u = one('SELECT u.* FROM users u JOIN roles r ON r.id=u.role_id WHERE u.email=? AND r.code=? AND u.is_active=1 FOR UPDATE', [$email, $portal]);
        if (!$u) {
            return;
        }

        $raw = token();
        query('UPDATE password_reset_tokens SET used_at=UTC_TIMESTAMP(3) WHERE user_id=? AND used_at IS NULL', [$u['id']]);
        $id = insert('INSERT INTO password_reset_tokens(user_id,portal,token_hash,expires_at) VALUES (?,?,?,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL 30 MINUTE))', [$u['id'], $portal, digest($raw)]);
        queueMail((int) $u['id'], null, $email, 'password_reset', 'STOR — إعادة تعيين كلمة المرور', ['name' => $u['full_name'], 'minutes' => 30, 'resetId' => $id, 'link' => rtrim(config()['origin'], '/').'/reset-password.html#reset-password/'.$raw.'/'.$portal], 'reset:'.$id);
    }
    );
    $delay = max(0, 300000 - (int) ((microtime(true) - $started) * 1000000));
    usleep($delay);

    return ['message' => 'إذا كان البريد مسجلًا فستصلك رسالة لإعادة تعيين كلمة المرور.'];
}

function resetPassword(array $d): array
{
    rateLimit('reset-password', 10);
    $raw = text($d, 'token', 64, 64);
    $portal = $d['portal'] ?? '';
    if (!preg_match('/^[a-f0-9]{64}$/', $raw) || !in_array($portal, ['customer', 'admin'], true)) {
        fail(400, 'الرابط غير صحيح.');
    }

    $hash = passwordHash(passwordInput($d));
    $candidate = one('SELECT id,user_id FROM password_reset_tokens WHERE token_hash=? AND portal=? AND used_at IS NULL AND expires_at>UTC_TIMESTAMP(3)', [digest($raw), $portal]);
    if (!$candidate) {
        fail(400, 'رابط غير صالح أو منتهي.');
    }
    transaction(function () use ($candidate, $hash) {
        one('SELECT id FROM users WHERE id=? FOR UPDATE', [$candidate['user_id']]);
        $valid = one('SELECT id FROM password_reset_tokens WHERE id=? AND used_at IS NULL AND expires_at>UTC_TIMESTAMP(3) FOR UPDATE', [$candidate['id']]);
        if (!$valid) {
            fail(400, 'رابط غير صالح أو مستخدم.');
        }

        query('UPDATE users SET password_hash=?,password_changed_at=UTC_TIMESTAMP(3) WHERE id=?', [$hash, $candidate['user_id']]);
        query('UPDATE password_reset_tokens SET used_at=UTC_TIMESTAMP(3) WHERE user_id=? AND used_at IS NULL', [$candidate['user_id']]);
        query('DELETE FROM sessions WHERE user_id=?', [$candidate['user_id']]);
        authEvent((int) $candidate['user_id'], 'password_reset', true);
    }
    );

    return ['message' => 'تم تغيير كلمة المرور. سجّل الدخول من جديد.'];
}
