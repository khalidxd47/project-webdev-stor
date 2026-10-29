<?php

/** اختبارات نطاق إضافية؛ لا تعمل إلا على قاعدة تنتهي بـ _test. */
require __DIR__.'/../app/bootstrap.php';
require ROOT.'/app/auth.php';
require ROOT.'/app/catalog.php';
require ROOT.'/app/orders.php';
require ROOT.'/app/mail.php';
if (PHP_SAPI !== 'cli' || !str_ends_with(config()['db']['name'], '_test')) {
    fwrite(STDERR, "Tests require CLI and a dedicated *_test database.\n");
    exit(1);
}

function check(bool $ok, string $name): void
{
    if (!$ok) {
        throw new RuntimeException($name);
    }
    echo "PASS $name\n";
}

$_SERVER['REMOTE_ADDR'] = '127.0.0.'.random_int(2, 254);
$_SERVER['REQUEST_METHOD'] = 'GET';
try {
    $email = 'domain-'.bin2hex(random_bytes(5)).'@example.test';
    $old = bin2hex(random_bytes(16));
    $id = insert('INSERT INTO users(role_id,full_name,email,password_hash) VALUES (1,?,?,?)', ['Domain Test', $email, passwordHash($old)]);
    query('INSERT INTO customer_profiles(user_id) VALUES (?)', [$id]);
    $raw = token();
    query('INSERT INTO sessions(user_id,portal,token_hash,csrf_token,expires_at) VALUES (?,?,?,?,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL 1 DAY))', [$id, 'customer', digest($raw), token()]);
    forgotPassword(['email' => $email, 'portal' => 'customer']);
    $job = one("SELECT * FROM email_outbox WHERE user_id=? AND template='password_reset' ORDER BY id DESC LIMIT 1", [$id]);
    $payload = decryptPayload($job['payload_encrypted']);
    check(!str_contains($job['payload_encrypted'], $email) && !str_contains($job['payload_encrypted'], 'reset-password'), 'Encrypted reset payload');
    preg_match('~reset-password/([a-f0-9]{64})/customer~', $payload['link'], $m);
    $new = bin2hex(random_bytes(16));
    resetPassword(['token' => $m[1], 'portal' => 'customer', 'password' => $new]);
    check(password_verify($new, one('SELECT password_hash FROM users WHERE id=?', [$id])['password_hash']), 'New password persisted');
    check(!password_verify($old, one('SELECT password_hash FROM users WHERE id=?', [$id])['password_hash']), 'Old password rejected');
    check(0 === (int) one('SELECT COUNT(*) AS n FROM sessions WHERE user_id=?', [$id])['n'], 'Reset revokes sessions');
    $reused = false;
    try {
        resetPassword(['token' => $m[1], 'portal' => 'customer', 'password' => $new]);
    } catch (HttpError $e) {
        $reused = 400 === $e->status;
    }
    check($reused, 'Reset token single use');
    $p = ['sku' => 'DOMAIN-'.bin2hex(random_bytes(4)), 'name' => 'منتج الحذف', 'description' => 'وصف المنتج', 'tag' => 'اختبار', 'fit' => 'عادي', 'category' => 'tee', 'price' => 99, 'color' => '#805be0', 'active' => true, 'images' => [['path' => 'assets/images/front.png', 'alt' => 'اختبار']], 'sizes' => array_map(fn ($s) => ['code' => $s, 'stock' => 5], ['XS', 'S', 'M', 'L', 'XL', 'XXL'])];
    $admin = (int) one('SELECT id FROM users WHERE role_id=2 LIMIT 1')['id'];
    $product = saveProduct($admin, productInput($p));
    $order = checkout(['id' => $id, 'email' => $email], ['checkoutKey' => sprintf('%s-%s-%s-%s-%s', bin2hex(random_bytes(4)), bin2hex(random_bytes(2)), bin2hex(random_bytes(2)), bin2hex(random_bytes(2)), bin2hex(random_bytes(6))), 'items' => [['productId' => $product, 'size' => 'M', 'color' => '#805be0', 'quantity' => 2]], 'customer' => ['name' => 'Domain Test', 'phone' => '0501234567', 'city' => 'الرياض', 'district' => 'النخيل', 'street' => 'شارع الاختبار', 'postal' => '12345', 'carrier' => 'سمسا']])['order'];
    changeStatus($admin, (int) $order['id'], ['status' => 'cancelled', 'note' => 'اختبار', 'notify' => false]);
    $stock = (int) one('SELECT stock_quantity FROM product_sizes ps JOIN sizes s ON s.id=ps.size_id WHERE product_id=? AND s.code=?', [$product, 'M'])['stock_quantity'];
    check(5 === $stock, 'Cancel restores inventory');
    changeStatus($admin, (int) $order['id'], ['status' => 'cancelled', 'note' => 'اختبار', 'notify' => false]);
    check(5 === (int) one('SELECT stock_quantity FROM product_sizes ps JOIN sizes s ON s.id=ps.size_id WHERE product_id=? AND s.code=?', [$product, 'M'])['stock_quantity'], 'Repeated cancellation cannot restore twice');
    deleteProduct($admin, $product);
    check(0 === (int) one('SELECT is_active FROM products WHERE id=?', [$product])['is_active'], 'Referenced product archived');
    check('منتج الحذف' === getOrder((int) $order['id'])['items'][0]['name'], 'Historical invoice retained');
    $markup = renderInvoice($order);
    check(str_contains($markup, $order['invoiceNumber']) && !str_contains($markup, '{{'), 'Printable invoice template complete');
    echo "10 domain scenarios passed.\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'FAILED: '.$e->getMessage()."\n");
    exit(1);
}
