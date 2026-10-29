/** اختبارات سلوك الواجهة دون مكتبات؛ Node للاختبار فقط وليس لتشغيل الموقع. */
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const source = fs.readFileSync(path.join(root, 'public/assets/js/store.js'), 'utf8');
const results = [];
const test = async (name, fn) => { await fn(); results.push({ name, status: 'PASS' }); console.log('PASS ' + name); };
const getFunction = (start, end, context) => vm.runInNewContext('(' + source.slice(source.indexOf(start), source.indexOf(end)).trim() + ')', context);
(async () => {
  let productCalls = 0;
  const context = {
    PRODUCTS: [],
    state: { profile: { id: 1 }, cart: [], orders: [], favorites: [] },
    api: {
      products: async () => { ++productCalls; throw new Error('Catalog unavailable'); },
      orders: async () => ({ orders: [{ id: '3' }] }),
      order: async (id) => ({ order: { id } }),
      favorites: async () => { throw new Error('Favorites unavailable'); },
    },
    writeStorage() {}, navigate() {}, findProduct() {},
  };
  const load = getFunction('async function loadPageData(', 'async function logoutCustomer(', context);
  await test('Orders load even when the catalog endpoint fails', async () => {
    await load({ name: 'orders' }); assert.equal(context.state.orders[0].id, '3'); assert.equal(productCalls, 0);
  });
  await test('Invoice loads without fetching unrelated catalog data', async () => {
    await load({ name: 'invoice', id: '8' }); assert.equal(context.state.orders[0].id, '8'); assert.equal(productCalls, 0);
  });
  await test('Optional favorites failure does not break product details', async () => {
    context.PRODUCTS = [{ id: 1 }]; await load({ name: 'product', id: '1' });
  });
  await test('Required favorites failure remains visible and retryable', async () => {
    await assert.rejects(load({ name: 'favorites' }), /Favorites unavailable/);
  });
  await test('Unauthenticated protected page retains the return destination', async () => {
    context.state.profile = null; let saved; context.writeStorage = (key, value) => { saved = value; };
    assert.equal(await load({ name: 'invoice', id: '8' }), false); assert.equal(saved, 'invoice/8');
  });
  const languageContext = { window: {}, document: { title: 'الرئيسية | STOR', addEventListener() {} }, localStorage: { getItem: () => 'en' } };
  vm.runInNewContext(fs.readFileSync(path.join(root, 'public/assets/js/translations.js'), 'utf8'), languageContext);
  vm.runInNewContext(fs.readFileSync(path.join(root, 'public/assets/js/language.js'), 'utf8'), languageContext);
  const t = languageContext.window.STOR.t;
  await test('Navigation, product names and dynamic invoice details translate', async () => {
    assert.equal(t('طلباتي'), 'My orders'); assert.equal(t('تيشيرت Urban Club'), 'Urban Club Tee');
    assert.equal(t('المقاس M · لون مخصص (#805be0) · كمية 1'), 'Size: M · Custom color (#805be0) · Qty: 1');
    assert.equal(t('اللون أسود'), 'Color: Black'); assert.equal(t('17 منتجًا'), '17 products');
  });
  await test('Unknown customer names and addresses are preserved', async () => {
    assert.equal(t('اسم عميل خاص 123'), 'اسم عميل خاص 123');
  });
  await test('Localized strings retain surrounding layout whitespace', async () => {
    assert.equal(t('  الرئيسية \n'), '  Home \n');
  });
  await test('Shipping carrier values stay stable when option labels are translated', async () => {
    const checkout = fs.readFileSync(path.join(root, 'public/checkout.html'), 'utf8');
    for (const carrier of ['سبريد', 'سمسا', 'أرامكس']) assert.ok(checkout.includes(`<option value="${carrier}">${carrier}</option>`));
  });
  fs.writeFileSync(path.join(root, 'docs/frontend-test-results.json'), JSON.stringify({ date: new Date().toISOString(), results }, null, 2));
})().catch((error) => { console.error(error); process.exitCode = 1; });
