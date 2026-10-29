<?php

/** إنشاء إعدادات بمفتاح عشوائي دون استبدال إعدادات المالك. */
if (PHP_SAPI !== 'cli') {
    exit;
}

$path = __DIR__.'/../config/config.local.php';
if (file_exists($path)) {
    echo "Config already exists; unchanged.\n";
    exit;
}

$c = require __DIR__.'/../config/config.example.php';
$c['encryption_key'] = bin2hex(random_bytes(32));
file_put_contents($path, "<?php\nreturn ".var_export($c, true).";\n", LOCK_EX);
echo "Created config/config.local.php. Fill MySQL settings locally.\n";
