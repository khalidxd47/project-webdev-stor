/** لغة المتجر: اختيار محفوظ، اتجاه صحيح، وترجمة المحتوى الذي يصل من PHP. */
(() => {
  'use strict';
  const messages = window.STOR_MESSAGES || {};
  let language = 'ar';
  try {
    language = localStorage.getItem('stor-language') === 'en' ? 'en' : 'ar';
  } catch {}
  const originals = new WeakMap();
  const attributeSources = new WeakMap();
  const normalize = (text) => text.replace(/\s+/g, ' ').trim();

  function translate(text) {
    if (language !== 'en') return text;
    const source = normalize(text);
    if (messages[source]) return text.match(/^\s*/)[0] + messages[source] + text.match(/\s*$/)[0];
    if (source.endsWith(' | STOR')) return `${translate(source.slice(0, -7))} | STOR`;
    const patterns = [
      [/^الحقل (.+) غير صحيح\.$/, 'Invalid field: $1.'],
      [/^طول الحقل (.+) غير صحيح\.$/, 'Invalid length for $1.'],
      [/^رقم الطلب (.+)$/, 'Order number $1'],
      [/^طلب (.+)$/, 'Order $1'],
      [/^(\d+) قطع$/, '$1 items'],
      [/^(\d+) منتجات$/, '$1 products'],
      [/^(\d+) منتجًا$/, '$1 products'],
      [/^المقاس:? ([A-Z0-9]+)$/, 'Size: $1'],
      [/^الصورة (\d+)$/, 'Image $1'],
      [/^لون مخصص \((.+)\)$/, 'Custom color ($1)'],
      [/^(\d+) من (\d+)$/, '$1 of $2'],
      [/^السلة، (\d+) منتجات$/, 'Cart, $1 items'],
    ];
    for (const [pattern, replacement] of patterns) {
      if (pattern.test(source)) return source.replace(pattern, replacement);
    }
    if (source.startsWith('عرض ') && messages[source.slice(4)])
      return `View ${messages[source.slice(4)]}`;
    if (source.startsWith('اللون ') && messages[source.slice(6)])
      return `Color: ${messages[source.slice(6)]}`;
    if (source.startsWith('اللون '))
      return `Color: ${messages[source.slice(6)] || source.slice(6)}`;
    if (source.includes(' — الصورة الأصلية'))
      return `${messages[source.replace(' — الصورة الأصلية', '')] || source.replace(' — الصورة الأصلية', '')} — Original image`;
    if (source.endsWith(' باللون المختار'))
      return `${messages[source.replace(' باللون المختار', '')] || source.replace(' باللون المختار', '')} in your selected color`;
    if (source.startsWith('حذف ') && messages[source.slice(4)])
      return `Remove ${messages[source.slice(4)]}`;
    if (source.startsWith('معاينة ')) return 'Product preview in your selected color';
    return source
      .replace(/([\d٠-٩.,٬٫]+) ر\.س/g, 'SAR $1')
      .replace(/المقاس:? /g, 'Size: ')
      .replace(/ · كمية /g, ' · Qty: ')
      .replace(/لون مخصص/g, 'Custom color')
      .replace(
        / · (أسود|أبيض|رمادي|بنفسجي|أزرق|أحمر|أخضر) · /g,
        (_, color) => ` · ${messages[color]} · `,
      );
  }

  function translateNode(node) {
    if (node.nodeType !== Node.TEXT_NODE || !node.textContent.trim()) return;
    if (node.parentElement?.closest('script, style, textarea, [data-no-translate], .brand')) return;
    let record = originals.get(node);
    if (!record || node.textContent !== record.rendered) record = { source: node.textContent };
    const rendered = translate(record.source);
    if (node.textContent !== rendered) node.textContent = rendered;
    record.rendered = rendered;
    originals.set(node, record);
  }

  let titleRecord = { source: document.title, rendered: document.title };
  function apply(root = document.body) {
    if (document.title !== titleRecord.rendered) titleRecord.source = document.title;
    titleRecord.rendered = translate(titleRecord.source);
    if (document.title !== titleRecord.rendered) document.title = titleRecord.rendered;
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    while (walker.nextNode()) translateNode(walker.currentNode);
    root.querySelectorAll('[placeholder], [aria-label], img[alt], [title]').forEach((element) => {
      const records = attributeSources.get(element) || {};
      for (const key of ['placeholder', 'aria-label', 'alt', 'title']) {
        if (!element.hasAttribute(key)) continue;
        const value = element.getAttribute(key);
        let record = records[key];
        if (!record || record.rendered !== value) record = { source: value };
        const rendered = translate(record.source);
        if (value !== rendered) element.setAttribute(key, rendered);
        records[key] = { source: record.source, rendered };
      }
      attributeSources.set(element, records);
    });
  }

  function setLanguage(next) {
    language = next === 'en' ? 'en' : 'ar';
    try {
      localStorage.setItem('stor-language', language);
    } catch {}
    document.documentElement.lang = language;
    document.documentElement.dir = language === 'en' ? 'ltr' : 'rtl';
    document.querySelectorAll('[data-language-select]').forEach((select) => {
      select.value = language;
    });
    apply();
    document.dispatchEvent(new CustomEvent('stor:language', { detail: { language } }));
  }

  window.STOR = {
    t: translate,
    get language() {
      return language;
    },
  };
  document.addEventListener('DOMContentLoaded', () => {
    const host = document.querySelector(
      '.header-actions, .admin-header .container, .site-header .container',
    );
    if (host) {
      const label = document.createElement('label');
      label.className = 'language-switch';
      const select = document.createElement('select');
      select.dataset.languageSelect = '';
      select.setAttribute('aria-label', 'Language / اللغة');
      for (const [value, text] of [
        ['ar', 'العربية'],
        ['en', 'English'],
      ]) {
        const option = document.createElement('option');
        option.value = value;
        option.textContent = text;
        select.append(option);
      }
      select.addEventListener('change', () => setLanguage(select.value));
      label.append(select);
      host.append(label);
    }
    // التمييز يعمل قبل الشبكة، وفي صفحات المعلومات أيضًا.
    const file = location.pathname.split('/').pop() || 'index.html';
    const section = ['tracking.html', 'invoice.html', 'success.html'].includes(file)
      ? 'orders.html'
      : file === 'product.html'
        ? 'products.html'
        : file;
    document.querySelectorAll('nav a[href]').forEach((link) => {
      if (link.getAttribute('href') === section) link.setAttribute('aria-current', 'page');
      else link.removeAttribute('aria-current');
    });
    setLanguage(language);
    let scheduled = false;
    new MutationObserver(() => {
      if (scheduled) return;
      scheduled = true;
      requestAnimationFrame(() => {
        scheduled = false;
        apply();
      });
    }).observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true,
      attributes: true,
      attributeFilter: ['placeholder', 'aria-label', 'alt', 'title'],
    });
  });
})();
