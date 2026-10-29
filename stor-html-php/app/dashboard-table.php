<?php
/** جدول ناتج من استعلام PHP مباشر، لا من نص HTML داخل JavaScript. */
$logged = sessionInfo('admin');
$search = mb_substr(trim((string) ($_GET['q'] ?? '')), 0, 100);
$records = $logged ? products(true, $search) : [];
?> <?php if ($logged): ?>
<section
  class="container course-dashboard panel"
  id="database-dashboard"
>
  <h2>سجل المنتجات — PHP / MySQL</h2>
  <form
    method="get"
    action="dashboard.php"
    class="course-search"
  >
    <label for="db-search">بحث بالاسم أو الوصف أو رمز المنتج</label>
    <input
      id="db-search"
      type="search"
      name="q"
      value="<?= e($search) ?>"
      maxlength="100"
    />
    <button
      class="button"
      type="submit"
    >
      بحث
    </button>
    <a href="dashboard.php">عرض الكل</a>
  </form>
  <p id="database-count"><?= count($records) ?> منتجًا</p>
  <div class="table-wrap">
    <table>
      <caption>بيانات المنتجات من قاعدة MySQL مباشرة</caption>
      <thead>
        <tr>
          <th scope="col">id</th>
          <th scope="col">الاسم</th>
          <th scope="col">الوصف</th>
          <th scope="col">السعر</th>
          <th scope="col">الحالة</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($records as $r): ?>
        <tr>
          <td><?= $r['id'] ?></td>
          <td><?= e($r['name']) ?></td>
          <td><?= e($r['description']) ?></td>
          <td><?= e($r['price']) ?> ر.س</td>
          <td><?= $r['active']?'نشط':'مؤرشف' ?></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <p>للإضافة والتعديل والحذف افتح تبويب «المنتجات والمخزون» أعلى لوحة الإدارة.</p>
</section>
<?php endif; ?>
