/** تحقق JavaScript صريح قبل إرسال النماذج، مع إعادة التحقق داخل PHP. */
document.addEventListener('input', (event) => {
  if (event.target instanceof HTMLInputElement) event.target.setCustomValidity('');
});
document.addEventListener(
  'submit',
  (event) => {
    const form = event.target;
    if (!(form instanceof HTMLFormElement)) return;
    for (const input of form.querySelectorAll('input[type="email"]')) {
      input.setCustomValidity(
        input.value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input.value.trim())
          ? window.STOR?.t('أدخل بريدًا إلكترونيًا صحيحًا.') || 'أدخل بريدًا إلكترونيًا صحيحًا.'
          : '',
      );
    }
    for (const input of form.querySelectorAll('[required]')) {
      if (
        input instanceof HTMLInputElement &&
        ['text', 'email', 'search', 'tel'].includes(input.type) &&
        !input.value.trim()
      )
        input.setCustomValidity(window.STOR?.t('هذا الحقل مطلوب.') || 'هذا الحقل مطلوب.');
    }
    if (!form.checkValidity()) {
      event.preventDefault();
      event.stopImmediatePropagation();
      form.reportValidity();
    }
  },
  true,
);
