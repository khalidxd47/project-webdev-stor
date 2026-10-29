<?php

/** نقطة API واحدة؛ تعمل تحت Apache وphp -S. PHP فقط دون Node.js. */
require_once __DIR__.'/../app/bootstrap.php';
require_once ROOT.'/app/catalog.php';
require_once ROOT.'/app/auth.php';
require_once ROOT.'/app/orders.php';
require_once ROOT.'/app/mail.php';
secureHeaders();
header('Cache-Control: no-store');
try {
    $method = $_SERVER['REQUEST_METHOD'];
    $path = '/'.trim((string) ($_GET['route'] ?? ''), '/');
    if (!in_array($method, ['GET', 'HEAD'], true)) {
        if (($_SERVER['HTTP_ORIGIN'] ?? '') !== rtrim(config()['origin'], '/')) {
            fail(403, 'مصدر الطلب غير مسموح.');
        }

        if (!str_starts_with(strtolower($_SERVER['CONTENT_TYPE'] ?? ''), 'application/json')) {
            fail(415, 'أرسل JSON.');
        }

        if ((int) ($_SERVER['CONTENT_LENGTH'] ?? 0) > 102400) {
            fail(413, 'الطلب كبير جدًا.');
        }

        try {
            $d = json_decode(file_get_contents('php://input'), true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            fail(400, 'صيغة JSON غير صحيحة.');
        }

        if (!is_array($d)) {
            fail(400, 'الطلب غير صحيح.');
        }
    } else {
        $d = [];
    }

    rateLimit('api', 1200, 300);
    if ('GET' === $method && '/health' === $path) {
        one('SELECT 1');
        jsonResponse(['ok' => true, 'backend' => 'PHP']);
    }

    if ('GET' === $method && '/products' === $path) {
        jsonResponse(['products' => products(false, mb_substr((string) ($_GET['q'] ?? ''), 0, 100))]);
    }

    if ('GET' === $method && in_array($path, ['/auth/session', '/admin/session'], true)) {
        $s = sessionInfo('/admin/session' === $path ? 'admin' : 'customer');
        jsonResponse($s ? ['user' => $s['user'], 'csrf' => $s['csrf']] : ['user' => null, 'csrf' => null]);
    }

    if ('POST' === $method && '/auth/register' === $path) {
        jsonResponse(registerCustomer($d), 201);
    }

    if ('POST' === $method && in_array($path, ['/auth/login', '/admin/login'], true)) {
        jsonResponse(loginUser($d, '/admin/login' === $path ? 'admin' : 'customer'));
    }

    if ('POST' === $method && '/auth/forgot-password' === $path) {
        jsonResponse(forgotPassword($d));
    }

    if ('POST' === $method && '/auth/reset-password' === $path) {
        jsonResponse(resetPassword($d));
    }

    $admin = str_starts_with($path, '/admin/');
    $s = requireSession($admin ? 'admin' : 'customer');
    $uid = $s['user']['id'];
    if ('POST' === $method && in_array($path, ['/auth/logout', '/admin/logout'], true)) {
        query('DELETE FROM sessions WHERE id=?', [$s['id']]);
        sessionCookie($admin ? 'admin' : 'customer', '', time() - 3600);
        jsonResponse(['message' => 'تم تسجيل الخروج. حسابك محفوظ.']);
    }

    if (!$admin) {
        if ('/account' === $path && 'GET' === $method) {
            $profile = one('SELECT phone FROM customer_profiles WHERE user_id=?', [$uid]);
            jsonResponse(['user' => $s['user'] + ['phone' => $profile['phone'] ?? '']]);
        }

        if ('/account' === $path && 'PATCH' === $method) {
            $name = text($d, 'name', 3, 120);
            query('UPDATE users SET full_name=? WHERE id=?', [$name, $uid]);
            jsonResponse(['user' => array_merge($s['user'], ['name' => $name])]);
        }

        if ('/favorites' === $path && 'GET' === $method) {
            jsonResponse(['favorites' => array_map(fn ($r) => (int) $r['product_id'], all('SELECT product_id FROM favorites WHERE user_id=?', [$uid]))]);
        }

        if ('/favorites' === $path && 'POST' === $method) {
            $id = integer($d['productId'] ?? null);
            if (!is_bool($d['favorite'] ?? null)) {
                fail(400, 'خيار غير صحيح.');
            }

            if (!one('SELECT id FROM products WHERE id=?', [$id])) {
                fail(404, 'المنتج غير موجود.');
            }

            query($d['favorite'] ? 'INSERT IGNORE INTO favorites(user_id,product_id) VALUES (?,?)' : 'DELETE FROM favorites WHERE user_id=? AND product_id=?', [$uid, $id]);
            jsonResponse(['message' => 'حُفظت المفضلة.']);
        }

        if ('/addresses' === $path && 'GET' === $method) {
            jsonResponse(['addresses' => all('SELECT * FROM addresses WHERE user_id=? ORDER BY id DESC', [$uid])]);
        }

        if ('/addresses' === $path && 'POST' === $method) {
            $label = text($d, 'label', 1, 50);
            $city = text($d, 'city', 2, 100);
            $district = text($d, 'district', 2, 100);
            $street = text($d, 'street', 4, 255);
            $postal = text($d, 'postal', 0, 5);
            if (!preg_match('/^(\d{5})?$/', $postal)) {
                fail(400, 'الرمز البريدي غير صحيح.');
            }
            jsonResponse(['id' => insert('INSERT INTO addresses(user_id,label,city,district,street,postal_code) VALUES (?,?,?,?,?,?)', [$uid, $label, $city, $district, $street, $postal ?: null])], 201);
        }

        if (preg_match('~^/addresses/(\d+)$~', $path, $m) && 'DELETE' === $method) {
            if (!query('DELETE FROM addresses WHERE id=? AND user_id=?', [(int) $m[1], $uid])->rowCount()) {
                fail(404, 'العنوان غير موجود.');
            }
            jsonResponse(['message' => 'حُذف العنوان.']);
        }

        if ('/orders' === $path && 'GET' === $method) {
            jsonResponse(['orders' => listOrders($uid)]);
        }

        if ('/orders' === $path && 'POST' === $method) {
            jsonResponse(checkout($s['user'], $d), 201);
        }

        if (preg_match('~^/orders/(\d+)(/invoice)?$~', $path, $m) && 'GET' === $method) {
            $o = getOrder((int) $m[1], $uid);
            if (!empty($m[2])) {
                header('Content-Type: text/html; charset=utf-8');
                echo renderInvoice($o);
                exit;
            }
            jsonResponse(['order' => $o]);
        }
    } else {
        if ('/admin/dashboard' === $path && 'GET' === $method) {
            jsonResponse(['counts' => one("SELECT (SELECT COUNT(*) FROM products WHERE is_active=1) AS products,(SELECT COUNT(*) FROM users WHERE role_id=1) AS customers,(SELECT COUNT(*) FROM orders) AS orders,(SELECT COUNT(*) FROM orders WHERE status_code='pending') AS pending,(SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE status_code='delivered') AS deliveredRevenue"), 'smtpConfigured' => (bool) config()['smtp']['host']]);
        }

        if ('/admin/products' === $path && 'GET' === $method) {
            jsonResponse(['products' => products(true, mb_substr((string) ($_GET['q'] ?? ''), 0, 100))]);
        }

        if ('/admin/products' === $path && 'POST' === $method) {
            jsonResponse(['id' => saveProduct($uid, productInput($d)), 'message' => 'أُضيف المنتج.'], 201);
        }

        if (preg_match('~^/admin/products/(\d+)$~', $path, $m)) {
            if ('PUT' === $method) {
                saveProduct($uid, productInput($d), (int) $m[1]);
                jsonResponse(['message' => 'حُفظ المنتج.']);
            }

            if ('DELETE' === $method) {
                jsonResponse(deleteProduct($uid, (int) $m[1]));
            }
        }

        if ('/admin/customers' === $path && 'GET' === $method) {
            jsonResponse(['customers' => all('SELECT * FROM v_customers ORDER BY id DESC LIMIT 200')]);
        }

        if ('/admin/orders' === $path && 'GET' === $method) {
            jsonResponse(['orders' => listOrders()]);
        }

        if (preg_match('~^/admin/orders/(\d+)(/invoice)?$~', $path, $m) && 'GET' === $method) {
            $o = getOrder((int) $m[1]);
            if (!empty($m[2])) {
                header('Content-Type: text/html; charset=utf-8');
                echo renderInvoice($o);
                exit;
            }
            jsonResponse(['order' => $o]);
        }

        if (preg_match('~^/admin/orders/(\d+)/status$~', $path, $m) && 'PATCH' === $method) {
            jsonResponse(changeStatus($uid, (int) $m[1], $d));
        }

        if (preg_match('~^/admin/orders/(\d+)/send-invoice$~', $path, $m) && 'POST' === $method) {
            rateLimit('send-invoice', 30, 3600);
            $request = text($d, 'requestId', 36, 36);
            if (!preg_match('/^[a-f0-9-]{36}$/i', $request)) {
                fail(400, 'المعرف غير صحيح.');
            }

            $o = getOrder((int) $m[1]);
            $mail = transaction(function () use ($uid, $o, $request) {
                $mail = invoiceQueue($o, 'invoice:manual:'.$o['id'].':'.$request);
                audit($uid, 'send_invoice', 'order', (int) $o['id'], null, ['mailId' => $mail]);

                return $mail;
            }
            );
            jsonResponse(['mailId' => $mail, 'message' => 'أُضيفت الفاتورة لطابور البريد.'], 202);
        }

        if ('/admin/mail' === $path && 'GET' === $method) {
            jsonResponse(['messages' => all('SELECT id,order_id,template,recipient,subject,status,attempts,created_at,sent_at,last_error FROM email_outbox ORDER BY id DESC LIMIT 100'), 'smtpConfigured' => (bool) config()['smtp']['host']]);
        }

        if (preg_match('~^/admin/mail/(\d+)/retry$~', $path, $m) && 'POST' === $method) {
            rateLimit('retry-mail', 30, 3600);
            $r = query("UPDATE email_outbox SET status='queued',attempts=0,available_at=UTC_TIMESTAMP(3),last_error=NULL WHERE id=? AND status='failed' AND payload_encrypted IS NOT NULL", [(int) $m[1]]);
            if (!$r->rowCount()) {
                fail(409, 'يمكن إعادة محاولة الرسائل الفاشلة فقط.');
            }
            jsonResponse(['message' => 'أُعيدت الرسالة للطابور.']);
        }

        if ('/admin/audit' === $path && 'GET' === $method) {
            jsonResponse(['events' => all('SELECT a.id,a.action,a.entity_type,a.entity_id,a.before_data,a.after_data,a.created_at,u.full_name AS admin_name FROM admin_audit_log a JOIN users u ON u.id=a.admin_id ORDER BY a.id DESC LIMIT 100')]);
        }
    }

    fail(404, 'المسار غير موجود.');
} catch (HttpError $e) {
    jsonResponse(['message' => $e->getMessage()], $e->status);
} catch (PDOException $e) {
    $duplicate = ($e->errorInfo[1] ?? 0) === 1062;
    error_log('STOR database error: '.($e->errorInfo[1] ?? 'unknown'));
    jsonResponse(['message' => $duplicate ? 'البريد أو اسم المستخدم أو رمز المنتج مستخدم بالفعل.' : 'تعذر الاتصال أو إتمام عملية قاعدة البيانات.'], $duplicate ? 409 : 500);
} catch (Throwable $e) {
    error_log('STOR error: '.get_class($e));
    jsonResponse(['message' => 'تعذر إكمال العملية.'], 500);
}
