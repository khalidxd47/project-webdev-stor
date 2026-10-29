-- =============================================================
-- STOR / MySQL 8.0.16+ / InnoDB / utf8mb4
-- قاعدة واحدة مترابطة، وصلاحيات تطبيق منفصلة للعميل والأدمن.
-- لا يحذف هذا الملف بيانات موجودة. الترحيلات تطبق مرة واحدة فقط.
-- =============================================================

CREATE TABLE roles (
  id TINYINT UNSIGNED PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE COMMENT 'customer أو admin',
  name_ar VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id TINYINT UNSIGNED NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE,
  username VARCHAR(50) NULL UNIQUE COMMENT 'اسم دخول مستقل للأدمن',
  password_hash VARCHAR(255) NOT NULL COMMENT 'PHP password_hash Argon2id + salt؛ لا كلمة مرور صريحة',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at DATETIME(3) NULL,
  password_changed_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id),
  INDEX idx_users_role_created (role_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE customer_profiles (
  user_id BIGINT UNSIGNED PRIMARY KEY,
  phone VARCHAR(20) NULL,
  CONSTRAINT fk_customer_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE addresses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  label VARCHAR(50) NOT NULL DEFAULT 'العنوان الرئيسي',
  city VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  street VARCHAR(255) NOT NULL,
  postal_code VARCHAR(10) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_addresses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_addresses_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE sessions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  portal ENUM('customer','admin') NOT NULL,
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
  csrf_token CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  expires_at DATETIME(3) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_sessions_user (user_id),
  INDEX idx_sessions_expiry (expires_at)
) ENGINE=InnoDB;

CREATE TABLE password_reset_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  portal ENUM('customer','admin') NOT NULL,
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
  expires_at DATETIME(3) NOT NULL,
  used_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_reset_user (user_id, used_at),
  INDEX idx_reset_expiry (expires_at)
) ENGINE=InnoDB;

CREATE TABLE auth_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  event_type VARCHAR(40) NOT NULL,
  succeeded BOOLEAN NOT NULL,
  ip_hash CHAR(64) CHARACTER SET ascii NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_auth_event_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_auth_events_date (created_at),
  INDEX idx_auth_events_user (user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE rate_limits (
  bucket_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  hits INT UNSIGNED NOT NULL DEFAULT 1,
  expires_at DATETIME(3) NOT NULL,
  INDEX idx_rate_limits_expiry (expires_at)
) ENGINE=InnoDB;

CREATE TABLE categories (
  id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) NOT NULL UNIQUE,
  name_ar VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id SMALLINT UNSIGNED NOT NULL,
  sku VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(160) NOT NULL,
  description TEXT NOT NULL,
  tag VARCHAR(60) NOT NULL DEFAULT '',
  fit VARCHAR(100) NOT NULL DEFAULT '',
  price DECIMAL(10,2) NOT NULL,
  default_color CHAR(7) CHARACTER SET ascii NOT NULL DEFAULT '#181b22',
  is_active BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'تعطيل بدل حذف سجل مرتبط بطلب',
  version INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'منع استبدال تعديل أدمن أحدث',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id),
  CONSTRAINT chk_product_price CHECK (price > 0),
  CONSTRAINT chk_product_color CHECK (default_color REGEXP '^#[0-9A-Fa-f]{6}$'),
  INDEX idx_products_catalog (is_active, category_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE product_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  image_path VARCHAR(500) NOT NULL COMMENT 'مسار محلي أو رابط HTTPS موثوق',
  alt_text VARCHAR(200) NOT NULL DEFAULT '',
  sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uq_product_image_order (product_id, sort_order)
) ENGINE=InnoDB;

CREATE TABLE sizes (
  id TINYINT UNSIGNED PRIMARY KEY,
  code VARCHAR(8) NOT NULL UNIQUE,
  sort_order TINYINT UNSIGNED NOT NULL
) ENGINE=InnoDB;

CREATE TABLE product_sizes (
  product_id BIGINT UNSIGNED NOT NULL,
  size_id TINYINT UNSIGNED NOT NULL,
  stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, size_id),
  CONSTRAINT fk_stock_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_size FOREIGN KEY (size_id) REFERENCES sizes(id),
  CONSTRAINT chk_stock_quantity CHECK (stock_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE favorites (
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id, product_id),
  CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_favorite_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE order_statuses (
  code VARCHAR(30) PRIMARY KEY,
  name_ar VARCHAR(60) NOT NULL,
  sort_order TINYINT UNSIGNED NOT NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(40) NULL UNIQUE,
  user_id BIGINT UNSIGNED NOT NULL,
  status_code VARCHAR(30) NOT NULL DEFAULT 'pending',
  checkout_key CHAR(36) CHARACTER SET ascii NOT NULL COMMENT 'منع تكرار الطلب عند إعادة الإرسال',
  subtotal DECIMAL(12,2) NOT NULL,
  shipping_amount DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(12,2) GENERATED ALWAYS AS (subtotal + shipping_amount) STORED,
  payment_method ENUM('cash_on_delivery') NOT NULL DEFAULT 'cash_on_delivery',
  carrier VARCHAR(60) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_order_checkout (user_id, checkout_key),
  CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_order_status FOREIGN KEY (status_code) REFERENCES order_statuses(code),
  CONSTRAINT chk_order_amounts CHECK (subtotal >= 0 AND shipping_amount >= 0),
  INDEX idx_orders_user_date (user_id, created_at),
  INDEX idx_orders_status_date (status_code, created_at)
) ENGINE=InnoDB;

CREATE TABLE order_addresses (
  order_id BIGINT UNSIGNED PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  city VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  street VARCHAR(255) NOT NULL,
  postal_code VARCHAR(10) NULL,
  CONSTRAINT fk_order_address FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB COMMENT='نسخة ثابتة من بيانات التسليم وقت الطلب';

CREATE TABLE order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  size_id TINYINT UNSIGNED NOT NULL,
  product_name VARCHAR(160) NOT NULL COMMENT 'نسخة الاسم وقت الشراء',
  unit_price DECIMAL(10,2) NOT NULL COMMENT 'سعر الخادم وقت الشراء',
  quantity INT UNSIGNED NOT NULL,
  color_hex CHAR(7) CHARACTER SET ascii NOT NULL,
  line_total DECIMAL(12,2) GENERATED ALWAYS AS (unit_price * quantity) STORED,
  CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(id),
  CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT fk_order_item_size FOREIGN KEY (size_id) REFERENCES sizes(id),
  CONSTRAINT chk_order_item_quantity CHECK (quantity BETWEEN 1 AND 20),
  CONSTRAINT chk_order_item_price CHECK (unit_price > 0),
  CONSTRAINT chk_order_item_color CHECK (color_hex REGEXP '^#[0-9A-Fa-f]{6}$'),
  INDEX idx_order_items_order (order_id)
) ENGINE=InnoDB;

CREATE TABLE order_status_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  status_code VARCHAR(30) NOT NULL,
  changed_by BIGINT UNSIGNED NULL,
  note VARCHAR(500) NOT NULL DEFAULT '',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_history_order FOREIGN KEY (order_id) REFERENCES orders(id),
  CONSTRAINT fk_history_status FOREIGN KEY (status_code) REFERENCES order_statuses(code),
  CONSTRAINT fk_history_actor FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_history_order_date (order_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE invoices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL UNIQUE,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  issued_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_invoice_order FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB;

CREATE TABLE email_outbox (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_id BIGINT UNSIGNED NULL,
  template ENUM('invoice','order_status','password_reset') NOT NULL,
  recipient VARCHAR(254) NOT NULL,
  subject VARCHAR(255) NOT NULL,
  payload_encrypted MEDIUMTEXT NULL COMMENT 'AES-256-GCM؛ يحذف المحتوى بعد الإرسال',
  deduplication_key VARCHAR(100) NULL UNIQUE,
  status ENUM('queued','processing','sent','failed','cancelled') NOT NULL DEFAULT 'queued',
  attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
  available_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  locked_at DATETIME(3) NULL,
  sent_at DATETIME(3) NULL,
  last_error VARCHAR(500) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_mail_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_mail_order FOREIGN KEY (order_id) REFERENCES orders(id),
  INDEX idx_mail_worker (status, available_at),
  INDEX idx_mail_order (order_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE admin_audit_log (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  admin_id BIGINT UNSIGNED NOT NULL,
  action VARCHAR(60) NOT NULL,
  entity_type VARCHAR(40) NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  before_data JSON NULL,
  after_data JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_audit_admin FOREIGN KEY (admin_id) REFERENCES users(id),
  INDEX idx_audit_entity (entity_type, entity_id, created_at),
  INDEX idx_audit_admin (admin_id, created_at)
) ENGINE=InnoDB;

-- Views للعرض الأكاديمي؛ لا تتضمن كلمات المرور أو رموز الدخول.
CREATE VIEW v_customers AS
SELECT u.id, u.full_name, u.email, p.phone, u.is_active, u.created_at
FROM users u JOIN roles r ON r.id=u.role_id
LEFT JOIN customer_profiles p ON p.user_id=u.id WHERE r.code='customer';

CREATE VIEW v_admins AS
SELECT u.id, u.username, u.full_name, u.email, u.is_active, u.created_at
FROM users u JOIN roles r ON r.id=u.role_id WHERE r.code='admin';

CREATE VIEW v_order_summary AS
SELECT o.id, o.order_number, u.full_name AS customer_name, o.status_code,
       s.name_ar AS status_ar, o.subtotal, o.shipping_amount, o.total_amount,
       o.created_at, i.invoice_number
FROM orders o JOIN users u ON u.id=o.user_id
JOIN order_statuses s ON s.code=o.status_code
LEFT JOIN invoices i ON i.order_id=o.id;
