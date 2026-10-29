<?php
/** تحديث تصاميم مجموعة العرض فقط؛ لا يحذف العملاء أو الطلبات أو منتجات الأدمن. */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../app/bootstrap.php';
$designs = json_decode(file_get_contents(ROOT.'/database/designs.json'), true, 512, JSON_THROW_ON_ERROR);
if (one('SELECT version FROM schema_migrations WHERE version=?', ['designs-2026-10'])) {
    echo "Collection update already applied.\n";
    exit;
}
$changed = transaction(function () use ($designs) {
    $count = 0;
    foreach ($designs as $design) {
        $product = one('SELECT id,name,description FROM products WHERE sku=?', [$design['sku']]);
        if (!$product) { continue; }
        $oldNames = ['تيشيرت أسود','تيشيرت أبيض','تيشيرت رمادي','تيشيرت كحلي','سويتشرت رمادي',
            'تيشيرت بنفسجي','تيشيرت أزرق','تيشيرت أخضر','تيشيرت أحمر','تيشيرت بيج',
            'تيشيرت قطن رمادي','تيشيرت أسود واسع','تيشيرت أبيض كلاسيكي','سويتشرت كحلي','سويتشرت يومي'];
        if (!in_array($product['name'], $oldNames, true) && $product['name'] !== $design['name']) { continue; }
        $id = (int) $product['id'];
        // لا نستبدل صورة مخصصة أضافها الأدمن للمجموعة.
        $image = one('SELECT image_path FROM product_images WHERE product_id=? ORDER BY sort_order LIMIT 1', [$id]);
        if (!$image || !preg_match('~^assets/images/(image\d+\.png|design-\d+\.svg)$~', $image['image_path'])) { continue; }
        if ($product['name'] === $design['name'] && $product['description'] === $design['description'] && $image['image_path'] === $design['image']) { continue; }
        query('UPDATE products SET name=?,description=?,tag=?,version=version+1 WHERE id=?', [$design['name'], $design['description'], 'STOR Originals', $id]);
        query('UPDATE product_images SET image_path=?,alt_text=? WHERE product_id=? AND image_path=?', [$design['image'], $design['name'], $id, $image['image_path']]);
        ++$count;
    }
    query('INSERT INTO schema_migrations(version,checksum) VALUES (?,?)', ['designs-2026-10', hash_file('sha256', ROOT.'/database/designs.json')]);
    return $count;
});
echo "Updated {$changed} original collection products. Accounts, orders, prices and stock preserved.\n";
