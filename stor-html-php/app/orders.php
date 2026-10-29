<?php

/** الطلب والمخزون والفاتورة في معاملة واحدة. السعر يؤخذ من MySQL. */
function getOrder(int $id, ?int $owner = null): array
{
    $sql = 'SELECT o.*,s.name_ar AS status_ar,i.invoice_number,a.full_name,a.email,a.phone,a.city,a.district,a.street,a.postal_code FROM orders o JOIN order_statuses s ON s.code=o.status_code JOIN order_addresses a ON a.order_id=o.id JOIN invoices i ON i.order_id=o.id WHERE o.id=?';
    $p = [$id];
    if (null !== $owner) {
        $sql .= ' AND o.user_id=?';
        $p[] = $owner;
    }

    $o = one($sql, $p);
    if (!$o) {
        fail(404, 'الطلب غير موجود.');
    }

    $items = all('SELECT oi.*,s.code AS size FROM order_items oi JOIN sizes s ON s.id=oi.size_id WHERE oi.order_id=? ORDER BY oi.id', [$id]);
    $history = all('SELECT h.status_code,s.name_ar AS status,h.note,h.created_at AS date FROM order_status_history h JOIN order_statuses s ON s.code=h.status_code WHERE h.order_id=? ORDER BY h.id', [$id]);

    return ['id' => (string) $id, 'number' => $o['order_number'], 'userId' => (int) $o['user_id'], 'statusCode' => $o['status_code'], 'status' => $o['status_ar'], 'invoiceNumber' => $o['invoice_number'], 'date' => $o['created_at'], 'total' => (float) $o['total_amount'], 'subtotal' => (float) $o['subtotal'], 'shipping' => (float) $o['shipping_amount'], 'customer' => ['name' => $o['full_name'], 'email' => $o['email'], 'phone' => $o['phone'], 'city' => $o['city'], 'district' => $o['district'], 'street' => $o['street'], 'postal' => $o['postal_code'], 'shipper' => $o['carrier']], 'items' => array_map(fn ($i) => ['id' => (int) $i['product_id'], 'name' => $i['product_name'], 'price' => (float) $i['unit_price'], 'qty' => (int) $i['quantity'], 'color' => $i['color_hex'], 'size' => $i['size']], $items), 'history' => $history];
}

function listOrders(?int $owner = null): array
{
    $rows = all('SELECT id FROM orders'.(null === $owner ? '' : ' WHERE user_id=?').' ORDER BY id DESC LIMIT 100', null === $owner ? [] : [$owner]);

    return array_map(fn ($r) => getOrder((int) $r['id'], $owner), $rows);
}

function invoiceQueue(array $o, string $key): int
{
    return queueMail($o['userId'], (int) $o['id'], $o['customer']['email'], 'invoice', 'STOR — فاتورة طلبك', ['orderId' => $o['id']], $key);
}

function checkout(array $user, array $d): array
{
    rateLimit('checkout', 30, 3600);
    $key = text($d, 'checkoutKey', 36, 36);
    if (!preg_match('/^[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i', $key)) {
        fail(400, 'مفتاح الطلب غير صحيح.');
    }

    $c = $d['customer'] ?? [];
    foreach (['name' => [3, 120], 'phone' => [10, 20], 'city' => [2, 100], 'district' => [2, 100], 'street' => [4, 255], 'carrier' => [3, 30]] as $k => $range) {
        text($c, $k, ...$range);
    }

    if (!preg_match('/^(05\d{8}|\+9665\d{8})$/', $c['phone']) || !in_array($c['carrier'], ['سبريد', 'سمسا', 'أرامكس'], true) || !preg_match('/^(\d{5})?$/', $c['postal'] ?? '')) {
        fail(400, 'بيانات الشحن غير صحيحة.');
    }

    if (!is_array($d['items'] ?? null) || !count($d['items']) || count($d['items']) > 30) {
        fail(400, 'السلة غير صحيحة.');
    }

    $merged = [];
    foreach ($d['items'] as $i) {
        $id = integer($i['productId'] ?? null);
        $qty = integer($i['quantity'] ?? null, 1, 20);
        if (!in_array($i['size'] ?? '', ['XS', 'S', 'M', 'L', 'XL', 'XXL'], true) || !preg_match('/^#[a-f0-9]{6}$/i', $i['color'] ?? '')) {
            fail(400, 'اللون أو المقاس غير صحيح.');
        }

        $k = $id.'|'.$i['size'].'|'.strtolower($i['color']);
        $i['quantity'] = $qty + ($merged[$k]['quantity'] ?? 0);
        if ($i['quantity'] > 20) {
            fail(400, 'الحد الأعلى 20 قطعة.');
        }

        $merged[$k] = $i;
    }
    $items = array_values($merged);
    usort($items, fn ($a, $b) => ($a['productId'] <=> $b['productId']) ?: strcmp($a['size'], $b['size']));
    $r = transaction(function () use ($user, $key, $c, $items) {
        one('SELECT id FROM users WHERE id=? FOR UPDATE', [$user['id']]);
        $old = one('SELECT id FROM orders WHERE user_id=? AND checkout_key=?', [$user['id'], $key]);
        if ($old) {
            return ['id' => (int) $old['id'], 'repeated' => true];
        }

        $cents = 0;
        $snap = [];
        foreach ($items as $i) {
            $p = one('SELECT * FROM products WHERE id=? AND is_active=1 FOR UPDATE', [$i['productId']]);
            if (!$p) {
                fail(409, 'أحد المنتجات لم يعد متاحًا.');
            }

            $s = one('SELECT ps.size_id,ps.stock_quantity FROM product_sizes ps JOIN sizes s ON s.id=ps.size_id WHERE ps.product_id=? AND s.code=? FOR UPDATE', [$i['productId'], $i['size']]);
            if (!$s || $s['stock_quantity'] < $i['quantity']) {
                fail(409, 'الكمية المطلوبة غير متوفرة.');
            }

            query('UPDATE product_sizes SET stock_quantity=stock_quantity-? WHERE product_id=? AND size_id=?', [$i['quantity'], $i['productId'], $s['size_id']]);
            query('UPDATE products SET version=version+1 WHERE id=?', [$i['productId']]);
            $price = (int) round((float) $p['price'] * 100);
            $cents += $price * $i['quantity'];
            $snap[] = $i + ['sizeId' => $s['size_id'], 'name' => $p['name'], 'price' => $price / 100];
        }

        $id = insert('INSERT INTO orders(user_id,checkout_key,subtotal,shipping_amount,carrier) VALUES (?,?,?,?,?)', [$user['id'], $key, $cents / 100, 15, $c['carrier']]);
        $number = 'ST-'.str_pad((string) $id, 6, '0', STR_PAD_LEFT);
        query('UPDATE orders SET order_number=? WHERE id=?', [$number, $id]);
        query('INSERT INTO order_addresses(order_id,full_name,email,phone,city,district,street,postal_code) VALUES (?,?,?,?,?,?,?,?)', [$id, $c['name'], $user['email'], $c['phone'], $c['city'], $c['district'], $c['street'], ($c['postal'] ?? '') ?: null]);
        query('UPDATE customer_profiles SET phone=? WHERE user_id=?', [$c['phone'], $user['id']]);
        foreach ($snap as $i) {
            query('INSERT INTO order_items(order_id,product_id,size_id,product_name,unit_price,quantity,color_hex) VALUES (?,?,?,?,?,?,?)', [$id, $i['productId'], $i['sizeId'], $i['name'], $i['price'], $i['quantity'], $i['color']]);
        }

        query("INSERT INTO order_status_history(order_id,status_code,changed_by,note) VALUES (?,'pending',?,'تم إنشاء الطلب')", [$id, $user['id']]);
        query('INSERT INTO invoices(order_id,invoice_number) VALUES (?,?)', [$id, 'INV-'.gmdate('Y').'-'.str_pad((string) $id, 6, '0', STR_PAD_LEFT)]);
        invoiceQueue(getOrder($id), 'invoice:auto:'.$id);

        return ['id' => $id, 'repeated' => false];
    }
    );

    return ['order' => getOrder($r['id'], $user['id']), 'repeated' => $r['repeated']];
}

function changeStatus(int $admin, int $id, array $d): array
{
    $next = $d['status'] ?? '';
    $note = text($d, 'note', 0, 500);
    if (!is_bool($d['notify'] ?? null)) {
        fail(400, 'خيار الإشعار غير صحيح.');
    }

    return transaction(function () use ($admin, $id, $d, $next, $note) {
        $o = one('SELECT * FROM orders WHERE id=? FOR UPDATE', [$id]);
        if (!$o) {
            fail(404, 'الطلب غير موجود.');
        }

        if ($o['status_code'] === $next) {
            return ['message' => 'الحالة لم تتغير.'];
        }

        $allowed = ['pending' => ['shipped', 'cancelled'], 'shipped' => ['out_for_delivery'], 'out_for_delivery' => ['delivered'], 'delivered' => [], 'cancelled' => []];
        if (!in_array($next, $allowed[$o['status_code']], true)) {
            fail(409, 'انتقال حالة الطلب غير مسموح.');
        }

        if ('cancelled' === $next) {
            foreach (all('SELECT product_id,size_id,SUM(quantity) AS qty FROM order_items WHERE order_id=? GROUP BY product_id,size_id ORDER BY product_id,size_id', [$id]) as $i) {
                one('SELECT id FROM products WHERE id=? FOR UPDATE', [$i['product_id']]);
                query('UPDATE product_sizes SET stock_quantity=stock_quantity+? WHERE product_id=? AND size_id=?', [$i['qty'], $i['product_id'], $i['size_id']]);
                query('UPDATE products SET version=version+1 WHERE id=?', [$i['product_id']]);
            }
        }

        query('UPDATE orders SET status_code=? WHERE id=?', [$next, $id]);
        $history = insert('INSERT INTO order_status_history(order_id,status_code,changed_by,note) VALUES (?,?,?,?)', [$id, $next, $admin, $note]);
        audit($admin, 'order_status', 'order', $id, ['status' => $o['status_code']], ['status' => $next, 'note' => $note]);
        if ($d['notify']) {
            $order = getOrder($id);
            queueMail((int) $o['user_id'], $id, $order['customer']['email'], 'order_status', 'STOR — تحديث حالة الطلب', ['name' => $order['customer']['name'], 'number' => $order['number'], 'status' => $order['status'], 'note' => $note, 'link' => rtrim(config()['origin'], '/').'/tracking.html?id='.$id], 'status:'.$history);
        }

        return ['message' => $d['notify'] ? 'حُفظت الحالة وأضيف البريد إلى الطابور.' : 'حُفظت الحالة.'];
    }
    );
}
