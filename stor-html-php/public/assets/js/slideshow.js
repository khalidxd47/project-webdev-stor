/** عرض شرائح قابل للإيقاف؛ يحترم تقليل الحركة. */
const slide = document.getElementById('slide-image');
if (slide) {
  const images = [
    ['assets/images/design-01.svg', 'تيشيرت أسود'],
    ['assets/images/design-02.svg', 'تيشيرت أبيض'],
    ['assets/images/design-03.svg', 'تيشيرت كحلي'],
    ['assets/images/design-05.svg', 'سويتشرت رمادي'],
  ];
  let index = 0;
  let paused = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const toggle = document.getElementById('slide-toggle');
  function show(delta) {
    index = (index + delta + images.length) % images.length;
    [slide.src, slide.alt] = images[index];
    document.getElementById('slide-caption').textContent = `${index + 1} من ${images.length}`;
  }
  function label() {
    toggle.textContent = paused ? 'تشغيل العرض' : 'إيقاف العرض';
    toggle.setAttribute('aria-pressed', String(paused));
  }
  document.getElementById('slide-prev').addEventListener('click', () => show(-1));
  document.getElementById('slide-next').addEventListener('click', () => show(1));
  toggle.addEventListener('click', () => {
    paused = !paused;
    label();
  });
  label();
  setInterval(() => {
    if (!paused && !document.hidden) show(1);
  }, 4000);
}

// جاهزية الصفحة بعد تحميل البيانات والتفاعلات.
document.body.dataset.ready = 'true';
