/** عميل HTTP فقط: جلسة HttpOnly في المتصفح وCSRF في الذاكرة، دون كلمات مرور مخزنة. */
let csrf = null;

export class ApiError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

async function request(path, { method = 'GET', body } = {}) {
  let response;
  try {
    response = await fetch(`api.php?route=${encodeURIComponent(path)}`, {
      method,
      credentials: 'same-origin',
      cache: 'no-store',
      signal: AbortSignal.timeout(12000),
      headers: {
        ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
        ...(csrf ? { 'X-CSRF-Token': csrf } : {}),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  } catch (error) {
    throw new ApiError(
      0,
      error.name === 'TimeoutError' ? 'انتهت مهلة الاتصال. أعد المحاولة.' : 'تعذر الاتصال بالخادم.',
    );
  }
  if (!(response.headers.get('content-type') || '').includes('application/json')) {
    throw new ApiError(response.status, 'الخادم لم يُرجع بيانات صحيحة. شغّل الموقع بواسطة PHP.');
  }
  const data = await response.json();
  if (!response.ok) throw new ApiError(response.status, data.message || 'تعذر الاتصال بالخادم.');
  return data;
}

async function authenticate(path, body) {
  const result = await request(path, { method: 'POST', body });
  csrf = result.csrf;
  return result;
}

export const api = {
  async session() {
    const result = await request('/auth/session');
    csrf = result.csrf;
    return result;
  },
  products: () => request('/products'),
  register: (body) => authenticate('/auth/register', body),
  login: (body) => authenticate('/auth/login', body),
  async logout() {
    const result = await request('/auth/logout', { method: 'POST', body: {} });
    csrf = null;
    return result;
  },
  forgot: (body) => request('/auth/forgot-password', { method: 'POST', body }),
  reset: (body) => request('/auth/reset-password', { method: 'POST', body }),
  orders: () => request('/orders'),
  order: (id) => request(`/orders/${encodeURIComponent(id)}`),
  checkout: (body) => request('/orders', { method: 'POST', body }),
  favorites: () => request('/favorites'),
  favorite: (body) => request('/favorites', { method: 'POST', body }),
  profile: (body) => request('/account', { method: 'PATCH', body }),
  addresses: () => request('/addresses'),
  addAddress: (body) => request('/addresses', { method: 'POST', body }),
  deleteAddress: (id) =>
    request(`/addresses/${encodeURIComponent(id)}`, { method: 'DELETE', body: {} }),
};
