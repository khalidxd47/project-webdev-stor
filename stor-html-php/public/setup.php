<?php
/** إعداد أول تشغيل على localhost فقط؛ يتوقف تلقائيًا بعد إنشاء الإعدادات. */
require_once __DIR__.'/../app/bootstrap.php';
secureHeaders();
if (!in_array($_SERVER['REMOTE_ADDR'] ?? '', ['127.0.0.1', '::1'], true)) {
    http_response_code(403);
    exit('الإعداد متاح على جهاز الخادم المحلي فقط.');
}
if (is_file(ROOT.'/config/config.local.php')) {
    http_response_code(404);
    exit('تم إعداد الموقع مسبقًا. افتح index.html.');
}
session_name('stor_install');
session_start(['cookie_httponly' => true, 'cookie_samesite' => 'Strict', 'use_strict_mode' => true]);
$_SESSION['csrf'] ??= bin2hex(random_bytes(32));
$host = $_SERVER['HTTP_HOST'] ?? 'localhost:8088';
if (!preg_match('/^[a-zA-Z0-9.\[\]:-]+$/', $host)) {
    http_response_code(400);
    exit('عنوان الخادم غير صحيح.');
}
$origin = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' ? 'https://' : 'http://').$host;
$error = '';
$values = ['db_host' => '127.0.0.1', 'db_port' => '3306', 'db_name' => 'stor_html', 'db_user' => 'root', 'admin_name' => '', 'admin_email' => '', 'admin_username' => ''];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $lock = null;
    try {
        if (!hash_equals($_SESSION['csrf'], (string) ($_POST['csrf'] ?? '')) || ($_SERVER['HTTP_ORIGIN'] ?? '') !== $origin) {
            fail(403, 'رمز الإعداد أو مصدر الطلب غير صحيح. حدّث الصفحة.');
        }
        foreach ($values as $key => $default) {
            $values[$key] = trim((string) ($_POST[$key] ?? ''));
        }
        $dbname = $values['db_name'];
        if (!preg_match('/^[a-zA-Z0-9_]{1,64}$/', $dbname)) {
            fail(400, 'اسم القاعدة: أحرف إنجليزية وأرقام وشرطة سفلية فقط.');
        }
        if (!preg_match('/^[a-zA-Z0-9.:-]{1,255}$/', $values['db_host'])) {
            fail(400, 'عنوان MySQL غير صحيح.');
        }
        $port = integer($values['db_port'], 1, 65535);
        $name = text(['name' => $values['admin_name']], 'name', 3, 120);
        $email = emailInput(['email' => $values['admin_email']]);
        $username = strtolower($values['admin_username']);
        if (!preg_match('/^[a-z0-9_.-]{3,50}$/', $username)) {
            fail(400, 'اسم دخول الأدمن 3 أحرف إنجليزية أو أكثر.');
        }
        $password = passwordInput(['password' => $_POST['admin_password'] ?? '']);
        if ($password !== ($_POST['admin_confirm'] ?? '')) {
            fail(400, 'كلمتا مرور الأدمن غير متطابقتين.');
        }
        if (empty($_POST['empty_database'])) {
            fail(400, 'أكّد استخدام قاعدة جديدة أو فارغة.');
        }
        $lock = fopen(ROOT.'/config/install.lock', 'c');
        if (!$lock || !flock($lock, LOCK_EX | LOCK_NB)) {
            fail(409, 'الإعداد قيد التنفيذ.');
        }
        if (is_file(ROOT.'/config/config.local.php')) {
            fail(409, 'تم إعداد الموقع بالفعل.');
        }
        $dbPassword = (string) ($_POST['db_password'] ?? '');
        $pdo = new PDO("mysql:host={$values['db_host']};port=$port;charset=utf8mb4", $values['db_user'], $dbPassword, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false]);
        $q = $pdo->prepare('SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name=?');
        $q->execute([$dbname]);
        if (!(int) $q->fetchColumn()) {
            $pdo->exec("CREATE DATABASE `$dbname` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
        }
        $q = $pdo->prepare('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=?');
        $q->execute([$dbname]);
        if ((int) $q->fetchColumn() !== 0) {
            fail(409, 'هذه القاعدة تحتوي جداول. اختر اسم قاعدة فارغة؛ لم نحذف بياناتك.');
        }
        $pdo->exec("USE `$dbname`");
        $pdo->exec(file_get_contents(ROOT.'/database/stor.sql'));
        $q = $pdo->prepare('INSERT INTO users(role_id,full_name,email,username,password_hash) VALUES (2,?,?,?,?)');
        $q->execute([$name, $email, $username, passwordHash($password)]);
        $config = require ROOT.'/config/config.example.php';
        $config['origin'] = $origin;
        $config['db'] = ['host' => $values['db_host'], 'port' => $port, 'name' => $dbname, 'user' => $values['db_user'], 'password' => $dbPassword, 'ssl_ca' => ''];
        $config['encryption_key'] = bin2hex(random_bytes(32));
        $file = fopen(ROOT.'/config/config.local.php', 'x');
        if (!$file) {
            fail(500, 'تعذّر حفظ الإعدادات. امنح PHP صلاحية الكتابة على مجلد config.');
        }
        fwrite($file, "<?php\n\nreturn ".var_export($config, true).";\n");
        fclose($file);
        session_destroy();
        header('Location: index.html?installed=1', true, 303);
        exit;
    } catch (HttpError $exception) {
        $error = $exception->getMessage();
    } catch (PDOException $exception) {
        $error = 'تعذر الاتصال أو إنشاء الجداول. تأكد من تشغيل MySQL واسم المستخدم وكلمة المرور وصلاحياته. رقم الخطأ: '.(string) ($exception->errorInfo[1] ?? $exception->getCode());
    } catch (Throwable $exception) {
        $error = 'تعذر الإعداد. تأكد من تفعيل PDO MySQL وmbstring وOpenSSL ودعم Argon2id في PHP.';
    } finally {
        if (is_resource($lock)) {
            flock($lock, LOCK_UN);
            fclose($lock);
        }
    }
}
?>
<!doctype html>
<html
  lang="ar"
  dir="rtl"
>
  <head>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />
    <title>إعداد STOR لأول مرة</title>
    <link
      rel="icon"
      href="assets/images/favicon.svg"
    />
    <link
      rel="stylesheet"
      href="assets/css/style.css"
    />
    <link
      rel="stylesheet"
      href="assets/css/setup.css"
    />
  </head>
  <body>
    <header class="site-header">
      <div class="container header-layout">
        <a
          class="brand"
          href="index.html"
        >
          ST
          <span>O</span>
          R
        </a>
        <span>إعداد أول تشغيل</span>
      </div>
    </header>
    <main class="container setup-main">
      <h1>نجهّز متجرك محليًا</h1>
      <p class="muted">
        شغّل MySQL، ثم أدخل بيانات الاتصال واختر حساب أدمن خاصًا بك. لن تُحذف أي قاعدة موجودة.
      </p>
      <?php if ($error !== ''): ?>
      <p
        class="setup-error"
        role="alert"
      >
        <?= e($error) ?>
      </p>
      <?php endif; ?>
      <form
        method="post"
        action="setup.php"
        class="panel setup-form"
      >
        <input
          type="hidden"
          name="csrf"
          value="<?= e($_SESSION['csrf']) ?>"
        />
        <fieldset>
          <legend>1. الاتصال بقاعدة MySQL</legend>
          <label for="db-host">الخادم</label>
          <input
            id="db-host"
            name="db_host"
            value="<?= e($values['db_host']) ?>"
            required
          />
          <label for="db-port">المنفذ</label>
          <input
            id="db-port"
            name="db_port"
            type="number"
            min="1"
            max="65535"
            value="<?= e($values['db_port']) ?>"
            required
          />
          <label for="db-name">اسم قاعدة جديدة أو فارغة</label>
          <input
            id="db-name"
            name="db_name"
            pattern="[a-zA-Z0-9_]+"
            value="<?= e($values['db_name']) ?>"
            required
          />
          <label for="db-user">مستخدم MySQL</label>
          <input
            id="db-user"
            name="db_user"
            value="<?= e($values['db_user']) ?>"
            required
          />
          <label for="db-password">كلمة مرور MySQL</label>
          <input
            id="db-password"
            name="db_password"
            type="password"
            autocomplete="off"
          />
          <label class="setup-check">
            <input
              type="checkbox"
              name="empty_database"
              value="1"
              required
            />
            أوافق على تجهيز قاعدة جديدة/فارغة بـ15 منتجًا تجريبيًا.
          </label>
        </fieldset>
        <fieldset>
          <legend>2. حساب إدارة المتجر</legend>
          <label for="admin-name">الاسم الكامل</label>
          <input
            id="admin-name"
            name="admin_name"
            minlength="3"
            value="<?= e($values['admin_name']) ?>"
            required
          />
          <label for="admin-email">البريد الإلكتروني</label>
          <input
            id="admin-email"
            name="admin_email"
            type="email"
            value="<?= e($values['admin_email']) ?>"
            required
          />
          <label for="admin-username">اسم الدخول بالإنجليزي</label>
          <input
            id="admin-username"
            name="admin_username"
            pattern="[a-zA-Z0-9_.-]{3,50}"
            value="<?= e($values['admin_username']) ?>"
            required
          />
          <label for="admin-password">كلمة مرور الأدمن — 12 حرفًا على الأقل</label>
          <input
            id="admin-password"
            name="admin_password"
            type="password"
            minlength="12"
            autocomplete="new-password"
            required
          />
          <label for="admin-confirm">تأكيد كلمة المرور</label>
          <input
            id="admin-confirm"
            name="admin_confirm"
            type="password"
            minlength="12"
            autocomplete="new-password"
            required
          />
        </fieldset>
        <button
          class="button button-primary"
          type="submit"
        >
          تجهيز الموقع وفتح المتجر
        </button>
      </form>
      <p class="note">
        معالج الإعداد يعمل على localhost فقط، ويغلق تلقائيًا بعد نجاحه. ملفات الإعدادات خارج المجلد
        العام.
      </p>
    </main>
    <footer class="site-footer container"><a href="index.html">STOR — متجر الملابس</a></footer>
  </body>
</html>
