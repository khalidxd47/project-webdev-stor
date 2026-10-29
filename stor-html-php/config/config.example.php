<?php

/** إعدادات محلية فقط. ينشئها scripts/config-init.php ولا تنشر إلى Git. */
return [
    'origin' => 'http://127.0.0.1:8088',
    'db' => ['host' => '127.0.0.1', 'port' => 3306, 'name' => 'stor_html', 'user' => 'stor_html_app', 'password' => '', 'ssl_ca' => ''],
    'encryption_key' => '', 'session_days' => 7,
    'smtp' => ['host' => '', 'port' => 587, 'secure' => false, 'user' => '', 'password' => '', 'from_email' => 'store@example.com', 'from_name' => 'STOR'],
];
