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

-- بيانات مرجعية ومنتجات العرض فقط. لا عملاء وهميون ولا أدمن افتراضي.
INSERT INTO roles (id, code, name_ar) VALUES (1,'customer','عميل'),(2,'admin','أدمن');
INSERT INTO categories (id, code, name_ar) VALUES (1,'tee','تيشيرتات'),(2,'hoodie','سويتشرتات');
INSERT INTO sizes (id, code, sort_order) VALUES
  (1,'XS',1),(2,'S',2),(3,'M',3),(4,'L',4),(5,'XL',5),(6,'XXL',6);
INSERT INTO order_statuses (code, name_ar, sort_order) VALUES
  ('pending','قيد التجهيز',1),('shipped','تم الشحن',2),
  ('out_for_delivery','جاري التوصيل',3),('delivered','تم التسليم',4),('cancelled','ملغي',5);
INSERT INTO products (id,category_id,sku,name,description,tag,fit,price,default_color) VALUES
  (1,1,'TEE-BLACK','تيشيرت أسود','تيشيرت يومي بتصميم بسيط.','جديد','قصة عادية',120,'#181b22'),
  (2,1,'TEE-WHITE','تيشيرت أبيض','تيشيرت واسع ومريح.','أوفر سايز','أوفر سايز',95,'#eeeade'),
  (3,1,'TEE-GRAY','تيشيرت رمادي','تصميم كلاسيكي.','كلاسيك فيت','كلاسيك فيت',85,'#9ca3af'),
  (4,1,'TEE-NAVY','تيشيرت كحلي','قصة سليم فيت.','سليم فيت','سليم فيت',110,'#263b58'),
  (5,2,'HOODIE-GRAY','سويتشرت رمادي','سويتشرت بقصة مريحة.','سويتشرت','قصة مريحة',180,'#9ca3af');
INSERT INTO product_images (product_id,image_path,alt_text) VALUES
  (1,'assets/images/image5.png','تيشيرت أسود'),(2,'assets/images/image4.png','تيشيرت أبيض'),
  (3,'assets/images/image1.png','تيشيرت رمادي'),(4,'assets/images/image2.png','تيشيرت كحلي'),
  (5,'assets/images/image9.png','سويتشرت رمادي');

-- عشرة منتجات إضافية لاستيفاء 15 سجلًا، لكل منها id/name/description.
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (6,1,'STOR-006','تيشيرت بنفسجي','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',129,'#805be0');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (6,'assets/images/image6.png','تيشيرت بنفسجي');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (7,1,'STOR-007','تيشيرت أزرق','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',144,'#2863cd');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (7,'assets/images/image7.png','تيشيرت أزرق');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (8,1,'STOR-008','تيشيرت أخضر','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',99,'#168c70');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (8,'assets/images/image8.png','تيشيرت أخضر');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (9,1,'STOR-009','تيشيرت أحمر','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',114,'#d74456');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (9,'assets/images/image0.png','تيشيرت أحمر');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (10,1,'STOR-010','تيشيرت بيج','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',129,'#d6ba8c');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (10,'assets/images/image1.png','تيشيرت بيج');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (11,1,'STOR-011','تيشيرت قطن رمادي','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',144,'#6b7280');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (11,'assets/images/image2.png','تيشيرت قطن رمادي');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (12,1,'STOR-012','تيشيرت أسود واسع','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',99,'#181b22');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (12,'assets/images/image3.png','تيشيرت أسود واسع');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (13,1,'STOR-013','تيشيرت أبيض كلاسيكي','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',114,'#eeeade');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (13,'assets/images/image4.png','تيشيرت أبيض كلاسيكي');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (14,2,'STOR-014','سويتشرت كحلي','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',129,'#263b58');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (14,'assets/images/image9.png','سويتشرت كحلي');
INSERT INTO products(id,category_id,sku,name,description,tag,fit,price,default_color) VALUES (15,2,'STOR-015','سويتشرت يومي','قطعة يومية مريحة من مجموعة STOR مع اختيار اللون والمقاس.','مجموعة STOR','قصة مريحة',144,'#9ca3af');
INSERT INTO product_images(product_id,image_path,alt_text) VALUES (15,'assets/images/image9.png','سويتشرت يومي');
INSERT INTO product_sizes(product_id,size_id,stock_quantity) SELECT p.id,s.id,20 FROM products p CROSS JOIN sizes s;

UPDATE products SET name='تيشيرت Urban Club', description='تصميم URBAN CLUB بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='TEE-BLACK';
UPDATE product_images SET image_path='assets/images/design-01.svg',alt_text='تيشيرت Urban Club' WHERE product_id=1;

UPDATE products SET name='تيشيرت Good Energy', description='تصميم GOOD ENERGY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='TEE-WHITE';
UPDATE product_images SET image_path='assets/images/design-02.svg',alt_text='تيشيرت Good Energy' WHERE product_id=2;

UPDATE products SET name='تيشيرت Explore More', description='تصميم EXPLORE MORE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='TEE-GRAY';
UPDATE product_images SET image_path='assets/images/design-03.svg',alt_text='تيشيرت Explore More' WHERE product_id=3;

UPDATE products SET name='تيشيرت Midnight Studio', description='تصميم MIDNIGHT STUDIO بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='TEE-NAVY';
UPDATE product_images SET image_path='assets/images/design-04.svg',alt_text='تيشيرت Midnight Studio' WHERE product_id=4;

UPDATE products SET name='هودي Slow Sunday', description='تصميم SLOW SUNDAY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='HOODIE-GRAY';
UPDATE product_images SET image_path='assets/images/design-05.svg',alt_text='هودي Slow Sunday' WHERE product_id=5;

UPDATE products SET name='تيشيرت Create Your Way', description='تصميم CREATE YOUR WAY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-006';
UPDATE product_images SET image_path='assets/images/design-06.svg',alt_text='تيشيرت Create Your Way' WHERE product_id=6;

UPDATE products SET name='تيشيرت Ocean State', description='تصميم OCEAN STATE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-007';
UPDATE product_images SET image_path='assets/images/design-07.svg',alt_text='تيشيرت Ocean State' WHERE product_id=7;

UPDATE products SET name='تيشيرت Grow Daily', description='تصميم GROW DAILY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-008';
UPDATE product_images SET image_path='assets/images/design-08.svg',alt_text='تيشيرت Grow Daily' WHERE product_id=8;

UPDATE products SET name='تيشيرت No Limits', description='تصميم NO LIMITS بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-009';
UPDATE product_images SET image_path='assets/images/design-09.svg',alt_text='تيشيرت No Limits' WHERE product_id=9;

UPDATE products SET name='تيشيرت Desert Soul', description='تصميم DESERT SOUL بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-010';
UPDATE product_images SET image_path='assets/images/design-10.svg',alt_text='تيشيرت Desert Soul' WHERE product_id=10;

UPDATE products SET name='تيشيرت Offline Mode', description='تصميم OFFLINE MODE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-011';
UPDATE product_images SET image_path='assets/images/design-11.svg',alt_text='تيشيرت Offline Mode' WHERE product_id=11;

UPDATE products SET name='تيشيرت Stay Curious', description='تصميم STAY CURIOUS بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-012';
UPDATE product_images SET image_path='assets/images/design-12.svg',alt_text='تيشيرت Stay Curious' WHERE product_id=12;

UPDATE products SET name='تيشيرت Less Is More', description='تصميم LESS IS MORE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-013';
UPDATE product_images SET image_path='assets/images/design-13.svg',alt_text='تيشيرت Less Is More' WHERE product_id=13;

UPDATE products SET name='هودي After Hours', description='تصميم AFTER HOURS بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-014';
UPDATE product_images SET image_path='assets/images/design-14.svg',alt_text='هودي After Hours' WHERE product_id=14;

UPDATE products SET name='هودي Weekend Dept', description='تصميم WEEKEND DEPT. بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', tag='STOR Originals' WHERE sku='STOR-015';
UPDATE product_images SET image_path='assets/images/design-15.svg',alt_text='هودي Weekend Dept' WHERE product_id=15;

CREATE TABLE schema_migrations(version VARCHAR(50) PRIMARY KEY,checksum CHAR(64) NOT NULL,applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
INSERT INTO schema_migrations(version,checksum) VALUES ('php-1','5e8a44b067851c44600cc5b48073d7baf20df5e554e9bb38133fd860d8229329');
