> التحديث الأخير: دعم العربية والإنجليزية، إصلاح تحميل البيانات، و15 تصميمًا مختلفًا. راجع UPDATE.md عند ترقية نسخة قائمة.

# STOR — صفحات HTML منفصلة + PHP / MySQL

ابدأ بملف START-HERE.md.

```text
stor-html-php/
  START-WINDOWS.cmd       تشغيل محلي دون Node.js
  START-HERE.md           الخطوات الأولى
  public/
    index.html            الرئيسية
    products.html         كتالوج المنتجات
    product.html          التفاصيل واختيار اللون والمقاس
    cart.html             السلة
    checkout.html         نموذج إتمام الطلب
    success.html          نجاح الطلب
    orders.html           طلبات العميل
    tracking.html         تتبع الطلب
    invoice.html          الفاتورة
    login.html            الدخول
    register.html         التسجيل
    account.html          الحساب
    profile.html          تعديل البيانات
    favorites.html        المفضلة
    addresses.html        العناوين
    forgot-password.html  طلب الاستعادة
    reset-password.html   تعيين كلمة المرور
    about.html            عن المتجر وعرض الشرائح
    size-guide.html       جدول المقاسات وقائمة العناية
    shipping.html         جدول الشحن وخطوات الطلب
    dashboard.php         لوحة PHP والبحث والعرض من MySQL
    api.php               نقطة عمليات PHP
    setup.php             إعداد أول تشغيل محلي
    assets/
      css/                ملفات التنسيق فقط
      js/                 ملفات التفاعل فقط
      images/             الصور والشعار وfavicon
      media/              الملف الصوتي المحلي
  app/                    منطق PHP الخاص، خارج المجلد العام
  config/                 مثال الإعدادات، والملف الخاص عند الإعداد
  database/               SQL كامل + schema وseed للمراجعة
  scripts/                الإعداد الطرفي وعامل البريد
  tests/                  اختبارات بنية وPHP
  vendor/                 PHPMailer ومحمّل Composer
  docs/                   المطابقة والشرح ونتائج التحقق
```

كل صفحة HTML تتضمن HTML الخاص بها وترويسة وتذييلًا وروابط؛ لا تضمّن قالب PHP لعرض صفحات أخرى. القوالب الصغيرة داخل HTML هي مكونات متكررة فقط: بطاقة منتج أو سطر سلة أو رسالة انتظار.

الموقع يحافظ على ألوان STOR وتخصيص لون التيشيرت ومعاينة الصورة واختيار المقاس والسلة والحسابات والإدارة والطلبات والفواتير. تقرير الصفحتين وأسماء الفريق غير مرفقة، تنفيذًا لطلب الموقع فقط.
