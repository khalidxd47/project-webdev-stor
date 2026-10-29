<?php
/** خادم العرض المحلي: لا يكشف ملفات config أو app أو database. */
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if ($path === '/') {
    $target = is_file(__DIR__.'/config/config.local.php') ? '/index.html' : '/setup.php';
    header('Location: '.$target, true, 302);
    return true;
}
if (str_starts_with($path, '/api/')) {
    $_GET['route'] = substr($path, 5);
    require __DIR__.'/public/api.php';
    return true;
}
$file = realpath(__DIR__.'/public'.$path);
$public = realpath(__DIR__.'/public');
if ($file && str_starts_with($file, $public.DIRECTORY_SEPARATOR) && is_file($file)) {
    if (pathinfo($file, PATHINFO_EXTENSION) === 'php') {
        require $file;
        return true;
    }
    return false;
}
http_response_code(404);
echo '404 — الصفحة غير موجودة.';
