<?php

/** الكتالوج وإدارة المنتجات؛ لا تُقبل أسعار أو أسماء غير متحققة. */
function products(bool $inactive = false, string $search = ''): array
{
    $sql = 'SELECT p.*,c.code AS category FROM products p JOIN categories c ON c.id=p.category_id WHERE 1=1';
    $params = [];
    if (!$inactive) {
        $sql .= ' AND p.is_active=1';
    }

    if ('' !== $search) {
        $sql .= ' AND (p.name LIKE ? OR p.description LIKE ? OR p.sku LIKE ?)';
        $params = array_fill(0, 3, '%'.$search.'%');
    }

    $rows = all($sql.' ORDER BY p.id', $params);
    $images = all('SELECT * FROM product_images ORDER BY product_id,sort_order');
    $sizes = all('SELECT ps.*,s.code FROM product_sizes ps JOIN sizes s ON s.id=ps.size_id ORDER BY s.sort_order');

    return array_map(function ($p) use ($images, $sizes) {
        $stock = [];
        $photos = [];
        foreach ($sizes as $s) {
            if ($s['product_id'] == $p['id']) {
                $stock[] = ['code' => $s['code'], 'stock' => (int) $s['stock_quantity']];
            }
        }

        foreach ($images as $im) {
            if ($im['product_id'] == $p['id']) {
                $photos[] = ['path' => $im['image_path'], 'alt' => $im['alt_text']];
            }
        }

        return ['id' => (int) $p['id'], 'sku' => $p['sku'], 'name' => $p['name'], 'description' => $p['description'], 'price' => (float) $p['price'], 'tag' => $p['tag'], 'fit' => $p['fit'], 'category' => $p['category'], 'color' => $p['default_color'], 'active' => (bool) $p['is_active'], 'version' => (int) $p['version'], 'available' => count(array_filter($stock, fn ($s) => $s['stock'] > 0)) > 0, 'images' => $photos, 'sizes' => $stock, 'updatedAt' => $p['updated_at']];
    }, $rows);
}

function productInput(array $d): array
{
    $r = [];
    foreach (['sku' => [2, 50], 'name' => [3, 160], 'description' => [0, 4000], 'tag' => [0, 60], 'fit' => [0, 100], 'color' => [7, 7], 'category' => [3, 10]] as $k => $range) {
        $r[$k] = text($d, $k, ...$range);
    }

    if (!preg_match('/^#[a-f0-9]{6}$/i', $r['color']) || !in_array($r['category'], ['tee', 'hoodie'], true)) {
        fail(400, 'اللون أو التصنيف غير صحيح.');
    }

    if (!is_numeric($d['price'] ?? null) || $d['price'] <= 0 || $d['price'] > 99999999.99 || abs($d['price'] * 100 - round($d['price'] * 100)) > 0.00001) {
        fail(400, 'السعر غير صحيح.');
    }

    $r['price'] = (float) $d['price'];
    if (!is_bool($d['active'] ?? null)) {
        fail(400, 'حالة المنتج غير صحيحة.');
    }

    $r['active'] = (int) $d['active'];
    if (!is_array($d['images'] ?? null) || count($d['images']) < 1 || count($d['images']) > 10) {
        fail(400, 'أضف صورة واحدة على الأقل.');
    }

    foreach ($d['images'] as $image) {
        $p = text($image, 'path', 1, 500);
        if (!((preg_match('~^assets/[a-zA-Z0-9_./-]+\.(png|jpg|jpeg|webp|svg)$~i', $p) && !str_contains($p, '..')) || preg_match('~^https://[^\s<>"\x27]+$~i', $p))) {
            fail(400, 'مسار الصورة غير صحيح.');
        }
        text($image, 'alt', 0, 200);
    }

    $r['images'] = $d['images'];
    if (!is_array($d['sizes'] ?? null) || 6 !== count($d['sizes'])) {
        fail(400, 'يلزم إدخال المقاسات الستة.');
    }

    $seen = [];
    foreach ($d['sizes'] as $s) {
        if (!in_array($s['code'] ?? '', ['XS', 'S', 'M', 'L', 'XL', 'XXL'], true) || in_array($s['code'], $seen, true)) {
            fail(400, 'المقاسات غير صحيحة.');
        }

        $seen[] = $s['code'];
        integer($s['stock'] ?? null, 0, 1000000);
    }

    $r['sizes'] = $d['sizes'];
    if (isset($d['version'])) {
        $r['version'] = integer($d['version']);
    }

    return $r;
}

function saveProduct(int $admin, array $d, ?int $id = null): int
{
    return transaction(function () use ($admin, $d, $id) {
        $before = null;
        $category = one('SELECT id FROM categories WHERE code=?', [$d['category']]);
        if ($id) {
            $before = one('SELECT * FROM products WHERE id=? FOR UPDATE', [$id]);
            if (!$before) {
                fail(404, 'المنتج غير موجود.');
            }

            if ((int) $before['version'] !== ($d['version'] ?? 0)) {
                fail(409, 'تغيّر المنتج أو المخزون. حدّث البيانات.');
            }

            query('UPDATE products SET category_id=?,sku=?,name=?,description=?,tag=?,fit=?,price=?,default_color=?,is_active=?,version=version+1 WHERE id=?', [$category['id'], $d['sku'], $d['name'], $d['description'], $d['tag'], $d['fit'], $d['price'], $d['color'], $d['active'], $id]);
            query('DELETE FROM product_images WHERE product_id=?', [$id]);
        } else {
            $id = insert('INSERT INTO products(category_id,sku,name,description,tag,fit,price,default_color,is_active) VALUES (?,?,?,?,?,?,?,?,?)', [$category['id'], $d['sku'], $d['name'], $d['description'], $d['tag'], $d['fit'], $d['price'], $d['color'], $d['active']]);
        }

        foreach ($d['images'] as $i => $im) {
            query('INSERT INTO product_images(product_id,image_path,alt_text,sort_order) VALUES (?,?,?,?)', [$id, $im['path'], $im['alt'], $i]);
        }

        foreach ($d['sizes'] as $s) {
            $ref = one('SELECT id FROM sizes WHERE code=?', [$s['code']]);
            query('INSERT INTO product_sizes(product_id,size_id,stock_quantity) VALUES (?,?,?) ON DUPLICATE KEY UPDATE stock_quantity=VALUES(stock_quantity)', [$id, $ref['id'], $s['stock']]);
        }

        audit($admin, $before ? 'product_update' : 'product_create', 'product', $id, $before, $d);

        return $id;
    }
    );
}

function deleteProduct(int $admin, int $id): array
{
    return transaction(function () use ($admin, $id) {
        $before = one('SELECT * FROM products WHERE id=? FOR UPDATE', [$id]);
        if (!$before) {
            fail(404, 'المنتج غير موجود.');
        }

        if (one('SELECT id FROM order_items WHERE product_id=? LIMIT 1', [$id])) {
            query('UPDATE products SET is_active=0,version=version+1 WHERE id=?', [$id]);
            $message = 'أُرشف المنتج لارتباطه بطلبات سابقة.';
        } else {
            query('DELETE FROM favorites WHERE product_id=?', [$id]);
            query('DELETE FROM product_sizes WHERE product_id=?', [$id]);
            query('DELETE FROM product_images WHERE product_id=?', [$id]);
            query('DELETE FROM products WHERE id=?', [$id]);
            $message = 'حُذف المنتج من قاعدة البيانات.';
        }

        audit($admin, 'product_delete', 'product', $id, $before);

        return ['message' => $message];
    }
    );
}
