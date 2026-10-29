# مطابقة متطلبات مشروع CS3810T

نطاق هذه الحزمة: الموقع وموارده وقاعدة البيانات فقط، حسب طلب المستخدم السابق. تقرير PDF وأسماء الفريق والعرض الشفهي ليست ضمن الحزمة.

| المتطلب | التنفيذ الفعلي |
|---|---|
| 7 صفحات على الأقل | 20 ملف .html مستقل داخل public، مع dashboard.php إضافية |
| Page titles | title مختلف في كل ملف HTML، وتحديث عنوان التفاصيل بعد قراءة البيانات |
| Header & footer | عناصر header وfooter مكتوبة في كل صفحة، لا PHP include لصفحات HTML |
| Navigation menu | تنقل سطح المكتب وشريط الجوال وروابط المعلومات |
| 10+ images | 11 صورة PNG، ومعرض 10 صور في index.html |
| Click to view details | بطاقات المنتجات والصور تفتح product.html?id=... |
| Form | نماذج login/register/checkout/profile/addresses، وإدارة المنتجات |
| 2 tables | جدول المقاسات في size-guide.html وجدول الشحن في shipping.html، إضافة جداول الإدارة |
| Ordered & unordered lists | ol لخطوات القياس والطلب، وul للمزايا والعناية وحالات الطلب |
| Internal & external links | ملفات HTML مترابطة، ورابط W3C WAI الخارجي في التذييل |
| Embedded media | audio محلي في index.html: assets/media/stor-chime.wav |
| Logo + favicon | علامة STOR، وassets/images/favicon.svg في كل صفحة |
| نوعان من CSS | External لجميع التصميم في assets/css؛ مثال inline واحد في فقرة about.html لتحقيق شرط المقرر |
| أكثر من 8 ألوان | لوحة التصميم وألوان النص والحالات والأزرار واختيار لون المنتج |
| Class & ID selectors | .product-grid و.panel و.course-gallery، و#app وغيرها |
| :hover | الروابط والأزرار وبطاقات المعرض |
| Flexbox | الترويسة والتنقل وcourse-links وcourse-search |
| Grid | شبكة المنتجات ومعرض الصور وصفحة عن المتجر |
| Viewport meta | مكتوب في كل ملف HTML وdashboard.php وsetup.php |
| Media queries للهاتف والتابلت | 640 و960 في course.css، وأحجام إضافية في style.css |
| Phone/tablet/desktop | نتائج 84 حالة عرض محفوظة في responsive-results.json |
| Transform | تكبير صورة المعرض عند المرور |
| Filter | brightness في المعرض وتأثيرات الصور الأصلية |
| Transition | الانتقالات في الصور والأزرار والمعرض |
| JS item info on click | فتح التفاصيل، وقراءة بيانات المنتج، وتغيير اللون والمقاس والصورة |
| JS form validation | assets/js/validation.js + فحص تطابق كلمة المرور، مع تحقق PHP نهائي |
| Slideshow/animation | about.html وassets/js/slideshow.js: التالي والسابق والتشغيل والإيقاف |
| PHP & MySQL 15+ records | PHP PDO، و15 سجلًا فعليًا في products عند التثبيت |
| 3 fields per item | id/name/description إضافة السعر والتصنيف واللون والمخزون |
| Insert/update/delete | لوحة المنتجات، app/catalog.php وpublic/api.php. المنتج المرتبط بطلب يؤرشف، وغير المرتبط يحذف فعليًا |
| Display data on dashboard.php | جدول PHP مباشر في app/dashboard-table.php، مع حماية الأدمن |
| Simple search | نموذج GET في dashboard.php يستعمل LIKE محضّرًا للاسم والوصف وSKU |
| Folder & database file | الحزمة تشمل المشروع وvendor والصور والصوت وdatabase/stor.sql |

## مثال سريع لمراجعة الأكواد

افتح public/products.html: ستجد رأس الصفحة والتنقل والبحث والترتيب وشبكة المنتجات والتذييل، بأسطر منسقة. افتح public/product.html: ستجد معرض المنتج وخيارات اللون والمقاس والكمية. CSS في assets/css وJavaScript في assets/js، ومنطق قاعدة البيانات في app.
