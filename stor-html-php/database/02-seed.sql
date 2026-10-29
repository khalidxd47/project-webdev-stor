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
