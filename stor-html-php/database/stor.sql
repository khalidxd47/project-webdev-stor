-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 30 أكتوبر 2026 الساعة 13:20
-- إصدار الخادم: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `stor_html_dev`
--

-- --------------------------------------------------------

--
-- بنية الجدول `addresses`
--

CREATE TABLE `addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `label` varchar(50) NOT NULL DEFAULT 'العنوان الرئيسي',
  `city` varchar(100) NOT NULL,
  `district` varchar(100) NOT NULL,
  `street` varchar(255) NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `admin_audit_log`
--

CREATE TABLE `admin_audit_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` bigint(20) UNSIGNED NOT NULL,
  `action` varchar(60) NOT NULL,
  `entity_type` varchar(40) NOT NULL,
  `entity_id` bigint(20) UNSIGNED NOT NULL,
  `before_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`before_data`)),
  `after_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`after_data`)),
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `admin_audit_log`
--

INSERT INTO `admin_audit_log` (`id`, `admin_id`, `action`, `entity_type`, `entity_id`, `before_data`, `after_data`, `created_at`) VALUES
(1, 4, 'product_create', 'product', 16, NULL, '{\"sku\":\"AUDIT-01\",\"name\":\"Audit Tee\",\"description\":\"Audit test product\",\"tag\":\"Test\",\"fit\":\"Regular\",\"color\":\"#0e7c86\",\"category\":\"tee\",\"price\":50,\"active\":1,\"images\":[{\"path\":\"assets\\/images\\/design-01.svg\",\"alt\":\"x\"}],\"sizes\":[{\"code\":\"XS\",\"stock\":5},{\"code\":\"S\",\"stock\":5},{\"code\":\"M\",\"stock\":5},{\"code\":\"L\",\"stock\":5},{\"code\":\"XL\",\"stock\":5},{\"code\":\"XXL\",\"stock\":5}]}', '2026-10-30 11:49:35.589'),
(2, 4, 'product_update', 'product', 16, '{\"id\":16,\"category_id\":1,\"sku\":\"AUDIT-01\",\"name\":\"Audit Tee\",\"description\":\"Audit test product\",\"tag\":\"Test\",\"fit\":\"Regular\",\"price\":\"50.00\",\"default_color\":\"#0e7c86\",\"is_active\":1,\"version\":1,\"created_at\":\"2026-10-30 11:49:35.560\",\"updated_at\":\"2026-10-30 11:49:35.560\"}', '{\"sku\":\"AUDIT-01\",\"name\":\"Audit Tee Updated\",\"description\":\"Audit test product\",\"tag\":\"Test\",\"fit\":\"Regular\",\"color\":\"#0e7c86\",\"category\":\"tee\",\"price\":50,\"active\":1,\"images\":[{\"path\":\"assets\\/images\\/design-01.svg\",\"alt\":\"x\"}],\"sizes\":[{\"code\":\"XS\",\"stock\":5},{\"code\":\"S\",\"stock\":5},{\"code\":\"M\",\"stock\":5},{\"code\":\"L\",\"stock\":5},{\"code\":\"XL\",\"stock\":5},{\"code\":\"XXL\",\"stock\":5}],\"version\":1}', '2026-10-30 11:49:36.155'),
(3, 4, 'product_delete', 'product', 16, '{\"id\":16,\"category_id\":1,\"sku\":\"AUDIT-01\",\"name\":\"Audit Tee Updated\",\"description\":\"Audit test product\",\"tag\":\"Test\",\"fit\":\"Regular\",\"price\":\"50.00\",\"default_color\":\"#0e7c86\",\"is_active\":1,\"version\":2,\"created_at\":\"2026-10-30 11:49:35.560\",\"updated_at\":\"2026-10-30 11:49:36.149\"}', NULL, '2026-10-30 11:49:36.382');

-- --------------------------------------------------------

--
-- بنية الجدول `auth_events`
--

CREATE TABLE `auth_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `event_type` varchar(40) NOT NULL,
  `succeeded` tinyint(1) NOT NULL,
  `ip_hash` char(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `auth_events`
--

INSERT INTO `auth_events` (`id`, `user_id`, `event_type`, `succeeded`, `ip_hash`, `created_at`) VALUES
(1, 1, 'register', 1, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-29 08:37:38.393'),
(2, 2, 'register', 1, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-29 08:37:46.976'),
(3, NULL, 'customer_login', 0, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-29 08:42:09.654'),
(4, NULL, 'customer_login', 0, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-29 08:42:09.997'),
(5, NULL, 'customer_login', 0, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-29 08:42:10.294'),
(6, 3, 'register', 1, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-29 08:43:30.720'),
(7, 4, 'admin_login', 1, '7fc18c9d0a06a5cddee0fde966a91e8a39a19b17f74d2228cdaf51ef0408f298', '2026-10-30 11:49:35.357'),
(8, 5, 'admin_login', 1, '660044074954773234ad2643f8b59dfb308ba6ef4aa12f1a1b83a4f96760ff06', '2026-10-30 12:13:32.618');

-- --------------------------------------------------------

--
-- بنية الجدول `categories`
--

CREATE TABLE `categories` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `code` varchar(40) NOT NULL,
  `name_ar` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `categories`
--

INSERT INTO `categories` (`id`, `code`, `name_ar`) VALUES
(1, 'tee', 'تيشيرتات'),
(2, 'hoodie', 'سويتشرتات');

-- --------------------------------------------------------

--
-- بنية الجدول `customer_profiles`
--

CREATE TABLE `customer_profiles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `phone` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `customer_profiles`
--

INSERT INTO `customer_profiles` (`user_id`, `phone`) VALUES
(1, NULL),
(2, NULL),
(3, '0512345678');

-- --------------------------------------------------------

--
-- بنية الجدول `email_outbox`
--

CREATE TABLE `email_outbox` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `template` enum('invoice','order_status','password_reset') NOT NULL,
  `recipient` varchar(254) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `payload_encrypted` mediumtext DEFAULT NULL COMMENT 'AES-256-GCM؛ يحذف المحتوى بعد الإرسال',
  `deduplication_key` varchar(100) DEFAULT NULL,
  `status` enum('queued','processing','sent','failed','cancelled') NOT NULL DEFAULT 'queued',
  `attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `available_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `locked_at` datetime(3) DEFAULT NULL,
  `sent_at` datetime(3) DEFAULT NULL,
  `last_error` varchar(500) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `email_outbox`
--

INSERT INTO `email_outbox` (`id`, `user_id`, `order_id`, `template`, `recipient`, `subject`, `payload_encrypted`, `deduplication_key`, `status`, `attempts`, `available_at`, `locked_at`, `sent_at`, `last_error`, `created_at`) VALUES
(1, 3, 1, 'invoice', 'flow-test@example.test', 'STOR — فاتورة طلبك', 'XlfSKsQIIkz96NfezhXaLfBFGnIr3F3cD1pnozjj5q39/c6cgTlOGRMWig==', 'invoice:auto:1', 'queued', 0, '2026-10-29 08:43:45.562', NULL, NULL, NULL, '2026-10-29 08:43:45.562');

-- --------------------------------------------------------

--
-- بنية الجدول `favorites`
--

CREATE TABLE `favorites` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `invoices`
--

CREATE TABLE `invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `issued_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `invoices`
--

INSERT INTO `invoices` (`id`, `order_id`, `invoice_number`, `issued_at`) VALUES
(1, 1, 'INV-2026-000001', '2026-10-29 08:43:45.555');

-- --------------------------------------------------------

--
-- بنية الجدول `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_number` varchar(40) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `status_code` varchar(30) NOT NULL DEFAULT 'pending',
  `checkout_key` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'منع تكرار الطلب عند إعادة الإرسال',
  `subtotal` decimal(12,2) NOT NULL,
  `shipping_amount` decimal(10,2) NOT NULL,
  `total_amount` decimal(12,2) GENERATED ALWAYS AS (`subtotal` + `shipping_amount`) STORED,
  `payment_method` enum('cash_on_delivery') NOT NULL DEFAULT 'cash_on_delivery',
  `carrier` varchar(60) NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updated_at` datetime(3) NOT NULL DEFAULT current_timestamp(3) ON UPDATE current_timestamp(3)
) ;

--
-- إرجاع أو استيراد بيانات الجدول `orders`
--

INSERT INTO `orders` (`id`, `order_number`, `user_id`, `status_code`, `checkout_key`, `subtotal`, `shipping_amount`, `payment_method`, `carrier`, `created_at`, `updated_at`) VALUES
(1, 'ST-000001', 3, 'pending', '024f2f1e-f061-4383-a783-57daca4637ac', 198.00, 15.00, 'cash_on_delivery', 'سبريد', '2026-10-29 08:43:45.539', '2026-10-29 08:43:45.540');

-- --------------------------------------------------------

--
-- بنية الجدول `order_addresses`
--

CREATE TABLE `order_addresses` (
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(254) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `city` varchar(100) NOT NULL,
  `district` varchar(100) NOT NULL,
  `street` varchar(255) NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='نسخة ثابتة من بيانات التسليم وقت الطلب';

--
-- إرجاع أو استيراد بيانات الجدول `order_addresses`
--

INSERT INTO `order_addresses` (`order_id`, `full_name`, `email`, `phone`, `city`, `district`, `street`, `postal_code`) VALUES
(1, 'Test Shopper', 'flow-test@example.test', '0512345678', 'الرياض', 'حي النخيل', 'شارع التجربة 12', NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `size_id` tinyint(3) UNSIGNED NOT NULL,
  `product_name` varchar(160) NOT NULL COMMENT 'نسخة الاسم وقت الشراء',
  `unit_price` decimal(10,2) NOT NULL COMMENT 'سعر الخادم وقت الشراء',
  `quantity` int(10) UNSIGNED NOT NULL,
  `color_hex` char(7) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `line_total` decimal(12,2) GENERATED ALWAYS AS (`unit_price` * `quantity`) STORED
) ;

--
-- إرجاع أو استيراد بيانات الجدول `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `size_id`, `product_name`, `unit_price`, `quantity`, `color_hex`) VALUES
(1, 1, 12, 3, 'تيشيرت Stay Curious', 99.00, 2, '#181b22');

-- --------------------------------------------------------

--
-- بنية الجدول `order_statuses`
--

CREATE TABLE `order_statuses` (
  `code` varchar(30) NOT NULL,
  `name_ar` varchar(60) NOT NULL,
  `sort_order` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `order_statuses`
--

INSERT INTO `order_statuses` (`code`, `name_ar`, `sort_order`) VALUES
('cancelled', 'ملغي', 5),
('delivered', 'تم التسليم', 4),
('out_for_delivery', 'جاري التوصيل', 3),
('pending', 'قيد التجهيز', 1),
('shipped', 'تم الشحن', 2);

-- --------------------------------------------------------

--
-- بنية الجدول `order_status_history`
--

CREATE TABLE `order_status_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `status_code` varchar(30) NOT NULL,
  `changed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `note` varchar(500) NOT NULL DEFAULT '',
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `order_status_history`
--

INSERT INTO `order_status_history` (`id`, `order_id`, `status_code`, `changed_by`, `note`, `created_at`) VALUES
(1, 1, 'pending', 3, 'تم إنشاء الطلب', '2026-10-29 08:43:45.553');

-- --------------------------------------------------------

--
-- بنية الجدول `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `portal` enum('customer','admin') NOT NULL,
  `token_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `expires_at` datetime(3) NOT NULL,
  `used_at` datetime(3) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` smallint(5) UNSIGNED NOT NULL,
  `sku` varchar(50) NOT NULL,
  `name` varchar(160) NOT NULL,
  `description` text NOT NULL,
  `tag` varchar(60) NOT NULL DEFAULT '',
  `fit` varchar(100) NOT NULL DEFAULT '',
  `price` decimal(10,2) NOT NULL,
  `default_color` char(7) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL DEFAULT '#181b22',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'تعطيل بدل حذف سجل مرتبط بطلب',
  `version` int(10) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'منع استبدال تعديل أدمن أحدث',
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updated_at` datetime(3) NOT NULL DEFAULT current_timestamp(3) ON UPDATE current_timestamp(3)
) ;

--
-- إرجاع أو استيراد بيانات الجدول `products`
--

INSERT INTO `products` (`id`, `category_id`, `sku`, `name`, `description`, `tag`, `fit`, `price`, `default_color`, `is_active`, `version`, `created_at`, `updated_at`) VALUES
(1, 1, 'TEE-BLACK', 'تيشيرت Urban Club', 'تصميم URBAN CLUB بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة عادية', 120.00, '#181b22', 1, 1, '2026-10-29 11:26:23.265', '2026-10-29 11:26:23.288'),
(2, 1, 'TEE-WHITE', 'تيشيرت Good Energy', 'تصميم GOOD ENERGY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'أوفر سايز', 95.00, '#eeeade', 1, 1, '2026-10-29 11:26:23.265', '2026-10-29 11:26:23.290'),
(3, 1, 'TEE-GRAY', 'تيشيرت Explore More', 'تصميم EXPLORE MORE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'كلاسيك فيت', 85.00, '#9ca3af', 1, 1, '2026-10-29 11:26:23.265', '2026-10-29 11:26:23.291'),
(4, 1, 'TEE-NAVY', 'تيشيرت Midnight Studio', 'تصميم MIDNIGHT STUDIO بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'سليم فيت', 110.00, '#263b58', 1, 1, '2026-10-29 11:26:23.265', '2026-10-29 11:26:23.292'),
(5, 2, 'HOODIE-GRAY', 'هودي Slow Sunday', 'تصميم SLOW SUNDAY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 180.00, '#9ca3af', 1, 1, '2026-10-29 11:26:23.265', '2026-10-29 11:26:23.294'),
(6, 1, 'STOR-006', 'تيشيرت Create Your Way', 'تصميم CREATE YOUR WAY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 129.00, '#805be0', 1, 1, '2026-10-29 11:26:23.269', '2026-10-29 11:26:23.296'),
(7, 1, 'STOR-007', 'تيشيرت Ocean State', 'تصميم OCEAN STATE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 144.00, '#2863cd', 1, 1, '2026-10-29 11:26:23.271', '2026-10-29 11:26:23.298'),
(8, 1, 'STOR-008', 'تيشيرت Grow Daily', 'تصميم GROW DAILY بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 99.00, '#168c70', 1, 1, '2026-10-29 11:26:23.272', '2026-10-29 11:26:23.300'),
(9, 1, 'STOR-009', 'تيشيرت No Limits', 'تصميم NO LIMITS بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 114.00, '#d74456', 1, 1, '2026-10-29 11:26:23.273', '2026-10-29 11:26:23.301'),
(10, 1, 'STOR-010', 'تيشيرت Desert Soul', 'تصميم DESERT SOUL بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 129.00, '#d6ba8c', 1, 1, '2026-10-29 11:26:23.274', '2026-10-29 11:26:23.304'),
(11, 1, 'STOR-011', 'تيشيرت Offline Mode', 'تصميم OFFLINE MODE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 144.00, '#6b7280', 1, 1, '2026-10-29 11:26:23.275', '2026-10-29 11:26:23.306'),
(12, 1, 'STOR-012', 'تيشيرت Stay Curious', 'تصميم STAY CURIOUS بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 99.00, '#181b22', 1, 2, '2026-10-29 11:26:23.277', '2026-10-29 08:43:45.538'),
(13, 1, 'STOR-013', 'تيشيرت Less Is More', 'تصميم LESS IS MORE بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 114.00, '#eeeade', 1, 1, '2026-10-29 11:26:23.278', '2026-10-29 11:26:23.309'),
(14, 2, 'STOR-014', 'هودي After Hours', 'تصميم AFTER HOURS بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 129.00, '#263b58', 1, 1, '2026-10-29 11:26:23.279', '2026-10-29 11:26:23.311'),
(15, 2, 'STOR-015', 'هودي Weekend Dept', 'تصميم WEEKEND DEPT. بطباعة مميزة وقصة مريحة. اختر المقاس واللون المناسبين لك.', 'STOR Originals', 'قصة مريحة', 144.00, '#9ca3af', 1, 1, '2026-10-29 11:26:23.281', '2026-10-29 11:26:23.313');

-- --------------------------------------------------------

--
-- بنية الجدول `product_images`
--

CREATE TABLE `product_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `image_path` varchar(500) NOT NULL COMMENT 'مسار محلي أو رابط HTTPS موثوق',
  `alt_text` varchar(200) NOT NULL DEFAULT '',
  `sort_order` smallint(5) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_path`, `alt_text`, `sort_order`) VALUES
(1, 1, 'assets/images/design-01.svg', 'تيشيرت Urban Club', 0),
(2, 2, 'assets/images/design-02.svg', 'تيشيرت Good Energy', 0),
(3, 3, 'assets/images/design-03.svg', 'تيشيرت Explore More', 0),
(4, 4, 'assets/images/design-04.svg', 'تيشيرت Midnight Studio', 0),
(5, 5, 'assets/images/design-05.svg', 'هودي Slow Sunday', 0),
(6, 6, 'assets/images/design-06.svg', 'تيشيرت Create Your Way', 0),
(7, 7, 'assets/images/design-07.svg', 'تيشيرت Ocean State', 0),
(8, 8, 'assets/images/design-08.svg', 'تيشيرت Grow Daily', 0),
(9, 9, 'assets/images/design-09.svg', 'تيشيرت No Limits', 0),
(10, 10, 'assets/images/design-10.svg', 'تيشيرت Desert Soul', 0),
(11, 11, 'assets/images/design-11.svg', 'تيشيرت Offline Mode', 0),
(12, 12, 'assets/images/design-12.svg', 'تيشيرت Stay Curious', 0),
(13, 13, 'assets/images/design-13.svg', 'تيشيرت Less Is More', 0),
(14, 14, 'assets/images/design-14.svg', 'هودي After Hours', 0),
(15, 15, 'assets/images/design-15.svg', 'هودي Weekend Dept', 0);

-- --------------------------------------------------------

--
-- بنية الجدول `product_sizes`
--

CREATE TABLE `product_sizes` (
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `size_id` tinyint(3) UNSIGNED NOT NULL,
  `stock_quantity` int(10) UNSIGNED NOT NULL DEFAULT 0
) ;

--
-- إرجاع أو استيراد بيانات الجدول `product_sizes`
--

INSERT INTO `product_sizes` (`product_id`, `size_id`, `stock_quantity`) VALUES
(1, 1, 20),
(1, 2, 20),
(1, 3, 20),
(1, 4, 20),
(1, 5, 20),
(1, 6, 20),
(2, 1, 20),
(2, 2, 20),
(2, 3, 20),
(2, 4, 20),
(2, 5, 20),
(2, 6, 20),
(3, 1, 20),
(3, 2, 20),
(3, 3, 20),
(3, 4, 20),
(3, 5, 20),
(3, 6, 20),
(4, 1, 20),
(4, 2, 20),
(4, 3, 20),
(4, 4, 20),
(4, 5, 20),
(4, 6, 20),
(5, 1, 20),
(5, 2, 20),
(5, 3, 20),
(5, 4, 20),
(5, 5, 20),
(5, 6, 20),
(6, 1, 20),
(6, 2, 20),
(6, 3, 20),
(6, 4, 20),
(6, 5, 20),
(6, 6, 20),
(7, 1, 20),
(7, 2, 20),
(7, 3, 20),
(7, 4, 20),
(7, 5, 20),
(7, 6, 20),
(8, 1, 20),
(8, 2, 20),
(8, 3, 20),
(8, 4, 20),
(8, 5, 20),
(8, 6, 20),
(9, 1, 20),
(9, 2, 20),
(9, 3, 20),
(9, 4, 20),
(9, 5, 20),
(9, 6, 20),
(10, 1, 20),
(10, 2, 20),
(10, 3, 20),
(10, 4, 20),
(10, 5, 20),
(10, 6, 20),
(11, 1, 20),
(11, 2, 20),
(11, 3, 20),
(11, 4, 20),
(11, 5, 20),
(11, 6, 20),
(12, 1, 20),
(12, 2, 20),
(12, 3, 18),
(12, 4, 20),
(12, 5, 20),
(12, 6, 20),
(13, 1, 20),
(13, 2, 20),
(13, 3, 20),
(13, 4, 20),
(13, 5, 20),
(13, 6, 20),
(14, 1, 20),
(14, 2, 20),
(14, 3, 20),
(14, 4, 20),
(14, 5, 20),
(14, 6, 20),
(15, 1, 20),
(15, 2, 20),
(15, 3, 20),
(15, 4, 20),
(15, 5, 20),
(15, 6, 20);

-- --------------------------------------------------------

--
-- بنية الجدول `rate_limits`
--

CREATE TABLE `rate_limits` (
  `bucket_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `hits` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `expires_at` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `rate_limits`
--

INSERT INTO `rate_limits` (`bucket_hash`, `hits`, `expires_at`) VALUES
('0c0d71b5d7e3f567641aa90da546533208148956576f4030c31254aac4d70e84', 3, '2026-10-29 09:37:38.680'),
('55f2a28bfb09051a4755410a09dbb1a0d9c3d77a90f2251cefb5edfaaccf634b', 3, '2026-10-29 08:52:38.128'),
('5adff95a62a88ed2b99d0a4a7eb8f89eb78627da4f1b90373b5e29d11b19f53d', 25, '2026-10-30 11:54:35.106'),
('829c217d9846b4f0575673de228b84f21684e247d1c9c709ee517abf40465a25', 17, '2026-10-30 12:17:36.272'),
('a4b43ce92a68b65516d9e967a8080258c5d9b404fbf5e4d353c29494278f330f', 1, '2026-10-30 12:28:32.057'),
('ac59bed94715028b97304feadc5ad350ba5d5a31fb7e54dc80a57567c0f0a03c', 1, '2026-10-30 12:04:35.108'),
('b0dda6d4b92aa85b351a17c18cb638fcc965656c9e03974ae07e17f7fdd22e6e', 3, '2026-10-29 08:57:09.463');

-- --------------------------------------------------------

--
-- بنية الجدول `roles`
--

CREATE TABLE `roles` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `code` varchar(20) NOT NULL COMMENT 'customer أو admin',
  `name_ar` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `roles`
--

INSERT INTO `roles` (`id`, `code`, `name_ar`) VALUES
(1, 'customer', 'عميل'),
(2, 'admin', 'أدمن');

-- --------------------------------------------------------

--
-- بنية الجدول `schema_migrations`
--

CREATE TABLE `schema_migrations` (
  `version` varchar(50) NOT NULL,
  `checksum` char(64) NOT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `schema_migrations`
--

INSERT INTO `schema_migrations` (`version`, `checksum`, `applied_at`) VALUES
('php-1', '5e8a44b067851c44600cc5b48073d7baf20df5e554e9bb38133fd860d8229329', '2026-10-29 08:26:23');

-- --------------------------------------------------------

--
-- بنية الجدول `sessions`
--

CREATE TABLE `sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `portal` enum('customer','admin') NOT NULL,
  `token_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `csrf_token` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `expires_at` datetime(3) NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `portal`, `token_hash`, `csrf_token`, `expires_at`, `created_at`) VALUES
(1, 1, 'customer', '0fe7f7997159ad2f9147bdf243f4b67f0aaf3fc9a7024fd7dd36ca329f5511ae', '61a39028b5b78579a6c785df1783246052c9c82e10d6dbadb9b5e5574f3f8a27', '2026-11-05 08:37:38.397', '2026-10-29 08:37:38.397'),
(2, 2, 'customer', '8536c2913a0d89d64914eb090de850ddb14f8d96304a2091749d2d8c4c84e574', '5be9d66ad894267d59cd8fa874e1d34266efc20557913fc61446bb94c010cf25', '2026-11-05 08:37:46.978', '2026-10-29 08:37:46.978'),
(3, 3, 'customer', '553fc159d2510495437008f16ba8cd74e3e48e742c15ddb0489532235ca31230', 'f5b04ea0a602aa1e62b1869828540a2cd381dbcd32dcc77f8796aac7351058d3', '2026-11-05 08:43:30.720', '2026-10-29 08:43:30.720'),
(4, 4, 'admin', '12f903e3a474e8291188976b6e622b4a32d0f503b8795127270276aeb2907188', '0fde6d2e2f95499acdb1765ee163d1879772db1940d9538328f3cd670689e4ee', '2026-11-06 11:49:35.359', '2026-10-30 11:49:35.359'),
(5, 5, 'admin', 'e00d5ce0bf923dd8ff9d94a584e84930cf970998bb90df54fb9cd0b6968e7f05', '2a939bf0571de39696927c94d6a2860dc05a8527e622f50de035e30daad9df4a', '2026-11-06 12:13:32.620', '2026-10-30 12:13:32.620');

-- --------------------------------------------------------

--
-- بنية الجدول `sizes`
--

CREATE TABLE `sizes` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `code` varchar(8) NOT NULL,
  `sort_order` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `sizes`
--

INSERT INTO `sizes` (`id`, `code`, `sort_order`) VALUES
(1, 'XS', 1),
(2, 'S', 2),
(3, 'M', 3),
(4, 'L', 4),
(5, 'XL', 5),
(6, 'XXL', 6);

-- --------------------------------------------------------

--
-- بنية الجدول `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` tinyint(3) UNSIGNED NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(254) NOT NULL,
  `username` varchar(50) DEFAULT NULL COMMENT 'اسم دخول مستقل للأدمن',
  `password_hash` varchar(255) NOT NULL COMMENT 'PHP password_hash Argon2id + salt؛ لا كلمة مرور صريحة',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime(3) DEFAULT NULL,
  `password_changed_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updated_at` datetime(3) NOT NULL DEFAULT current_timestamp(3) ON UPDATE current_timestamp(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`id`, `role_id`, `full_name`, `email`, `username`, `password_hash`, `is_active`, `last_login_at`, `password_changed_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'Test Shopper', 'test-19116@example.test', NULL, '$argon2id$v=19$m=65536,t=4,p=1$Qnl5dmFSbU02SHFoWkFYQQ$X9ZNytzKLvpZoSdQQXvnaRfDrdcynvGPe7Yjeu2mIVI', 1, NULL, '2026-10-29 08:37:38.374', '2026-10-29 08:37:38.374', '2026-10-29 08:37:38.374'),
(2, 1, 'Test Shopper', 'test-28454@example.test', NULL, '$argon2id$v=19$m=65536,t=4,p=1$dlcyNkZNNEkzckhDQS8zaw$skQNZ0jG1yDm8M4v6SRns7ONnHbnft9jP+q3G+N8mBg', 1, NULL, '2026-10-29 08:37:46.973', '2026-10-29 08:37:46.973', '2026-10-29 08:37:46.973'),
(3, 1, 'Test Shopper', 'flow-test@example.test', NULL, '$argon2id$v=19$m=65536,t=4,p=1$Z2JBNlFBOWZkR1l5VzNudA$JzRHS35LqiNyDWzXwqGygBQAZepw0pKUU3izADgQDO8', 1, NULL, '2026-10-29 08:43:30.718', '2026-10-29 08:43:30.718', '2026-10-29 08:43:30.718'),
(4, 2, 'Test Admin', 'admin-test@example.test', 'testadmin', '$argon2id$v=19$m=65536,t=4,p=1$T2ppYi5tVjNJN3AxbjZBYQ$JqKsw6BKQ6l56eNRx4PLNx+Wdl69ii76tWTYNlXMtwk', 1, '2026-10-30 11:49:35.356', '2026-10-30 11:49:33.767', '2026-10-30 11:49:33.767', '2026-10-30 11:49:35.356'),
(5, 2, 'khalid alothman', 'admin@gmail.com', 'khadmin', '$argon2id$v=19$m=65536,t=4,p=1$cWZ0OXNOclViYkNrcTlrMA$irtX6+fR9HBVPfTtWX9s2mx+lz6ih6+QHRtaMuFEwKI', 1, '2026-10-30 12:13:32.608', '2026-10-30 12:12:32.622', '2026-10-30 12:12:32.622', '2026-10-30 12:13:32.608');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_admins`
-- (See below for the actual view)
--
CREATE TABLE `v_admins` (
`id` bigint(20) unsigned
,`username` varchar(50)
,`full_name` varchar(120)
,`email` varchar(254)
,`is_active` tinyint(1)
,`created_at` datetime(3)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_customers`
-- (See below for the actual view)
--
CREATE TABLE `v_customers` (
`id` bigint(20) unsigned
,`full_name` varchar(120)
,`email` varchar(254)
,`phone` varchar(20)
,`is_active` tinyint(1)
,`created_at` datetime(3)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_order_summary`
-- (See below for the actual view)
--
CREATE TABLE `v_order_summary` (
`id` bigint(20) unsigned
,`order_number` varchar(40)
,`customer_name` varchar(120)
,`status_code` varchar(30)
,`status_ar` varchar(60)
,`subtotal` decimal(12,2)
,`shipping_amount` decimal(10,2)
,`total_amount` decimal(12,2)
,`created_at` datetime(3)
,`invoice_number` varchar(50)
);

-- --------------------------------------------------------

--
-- Structure for view `v_admins`
--
DROP TABLE IF EXISTS `v_admins`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_admins`  AS SELECT `u`.`id` AS `id`, `u`.`username` AS `username`, `u`.`full_name` AS `full_name`, `u`.`email` AS `email`, `u`.`is_active` AS `is_active`, `u`.`created_at` AS `created_at` FROM (`users` `u` join `roles` `r` on(`r`.`id` = `u`.`role_id`)) WHERE `r`.`code` = 'admin' ;

-- --------------------------------------------------------

--
-- Structure for view `v_customers`
--
DROP TABLE IF EXISTS `v_customers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_customers`  AS SELECT `u`.`id` AS `id`, `u`.`full_name` AS `full_name`, `u`.`email` AS `email`, `p`.`phone` AS `phone`, `u`.`is_active` AS `is_active`, `u`.`created_at` AS `created_at` FROM ((`users` `u` join `roles` `r` on(`r`.`id` = `u`.`role_id`)) left join `customer_profiles` `p` on(`p`.`user_id` = `u`.`id`)) WHERE `r`.`code` = 'customer' ;

-- --------------------------------------------------------

--
-- Structure for view `v_order_summary`
--
DROP TABLE IF EXISTS `v_order_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_order_summary`  AS SELECT `o`.`id` AS `id`, `o`.`order_number` AS `order_number`, `u`.`full_name` AS `customer_name`, `o`.`status_code` AS `status_code`, `s`.`name_ar` AS `status_ar`, `o`.`subtotal` AS `subtotal`, `o`.`shipping_amount` AS `shipping_amount`, `o`.`total_amount` AS `total_amount`, `o`.`created_at` AS `created_at`, `i`.`invoice_number` AS `invoice_number` FROM (((`orders` `o` join `users` `u` on(`u`.`id` = `o`.`user_id`)) join `order_statuses` `s` on(`s`.`code` = `o`.`status_code`)) left join `invoices` `i` on(`i`.`order_id` = `o`.`id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_addresses_user` (`user_id`);

--
-- Indexes for table `admin_audit_log`
--
ALTER TABLE `admin_audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`,`created_at`),
  ADD KEY `idx_audit_admin` (`admin_id`,`created_at`);

--
-- Indexes for table `auth_events`
--
ALTER TABLE `auth_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_auth_events_date` (`created_at`),
  ADD KEY `idx_auth_events_user` (`user_id`,`created_at`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `customer_profiles`
--
ALTER TABLE `customer_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `email_outbox`
--
ALTER TABLE `email_outbox`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `deduplication_key` (`deduplication_key`),
  ADD KEY `fk_mail_user` (`user_id`),
  ADD KEY `idx_mail_worker` (`status`,`available_at`),
  ADD KEY `idx_mail_order` (`order_id`,`created_at`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`user_id`,`product_id`),
  ADD KEY `fk_favorite_product` (`product_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_id` (`order_id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_order_checkout` (`user_id`,`checkout_key`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `idx_orders_user_date` (`user_id`,`created_at`),
  ADD KEY `idx_orders_status_date` (`status_code`,`created_at`);

--
-- Indexes for table `order_addresses`
--
ALTER TABLE `order_addresses`
  ADD PRIMARY KEY (`order_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_order_item_product` (`product_id`),
  ADD KEY `fk_order_item_size` (`size_id`),
  ADD KEY `idx_order_items_order` (`order_id`);

--
-- Indexes for table `order_statuses`
--
ALTER TABLE `order_statuses`
  ADD PRIMARY KEY (`code`);

--
-- Indexes for table `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_history_status` (`status_code`),
  ADD KEY `fk_history_actor` (`changed_by`),
  ADD KEY `idx_history_order_date` (`order_id`,`created_at`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `idx_reset_user` (`user_id`,`used_at`),
  ADD KEY `idx_reset_expiry` (`expires_at`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `fk_product_category` (`category_id`),
  ADD KEY `idx_products_catalog` (`is_active`,`category_id`,`created_at`);

--
-- Indexes for table `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_product_image_order` (`product_id`,`sort_order`);

--
-- Indexes for table `product_sizes`
--
ALTER TABLE `product_sizes`
  ADD PRIMARY KEY (`product_id`,`size_id`),
  ADD KEY `fk_stock_size` (`size_id`);

--
-- Indexes for table `rate_limits`
--
ALTER TABLE `rate_limits`
  ADD PRIMARY KEY (`bucket_hash`),
  ADD KEY `idx_rate_limits_expiry` (`expires_at`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `schema_migrations`
--
ALTER TABLE `schema_migrations`
  ADD PRIMARY KEY (`version`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `idx_sessions_user` (`user_id`),
  ADD KEY `idx_sessions_expiry` (`expires_at`);

--
-- Indexes for table `sizes`
--
ALTER TABLE `sizes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `idx_users_role_created` (`role_id`,`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admin_audit_log`
--
ALTER TABLE `admin_audit_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `auth_events`
--
ALTER TABLE `auth_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `email_outbox`
--
ALTER TABLE `email_outbox`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `fk_addresses_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `admin_audit_log`
--
ALTER TABLE `admin_audit_log`
  ADD CONSTRAINT `fk_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`);

--
-- قيود الجداول `auth_events`
--
ALTER TABLE `auth_events`
  ADD CONSTRAINT `fk_auth_event_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `customer_profiles`
--
ALTER TABLE `customer_profiles`
  ADD CONSTRAINT `fk_customer_profile_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `email_outbox`
--
ALTER TABLE `email_outbox`
  ADD CONSTRAINT `fk_mail_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_mail_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- قيود الجداول `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `fk_favorite_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `fk_invoice_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- قيود الجداول `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_order_status` FOREIGN KEY (`status_code`) REFERENCES `order_statuses` (`code`),
  ADD CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- قيود الجداول `order_addresses`
--
ALTER TABLE `order_addresses`
  ADD CONSTRAINT `fk_order_address` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- قيود الجداول `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_item_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_order_item_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `fk_order_item_size` FOREIGN KEY (`size_id`) REFERENCES `sizes` (`id`);

--
-- قيود الجداول `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD CONSTRAINT `fk_history_actor` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_history_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_history_status` FOREIGN KEY (`status_code`) REFERENCES `order_statuses` (`code`);

--
-- قيود الجداول `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD CONSTRAINT `fk_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- قيود الجداول `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `fk_image_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `product_sizes`
--
ALTER TABLE `product_sizes`
  ADD CONSTRAINT `fk_stock_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_stock_size` FOREIGN KEY (`size_id`) REFERENCES `sizes` (`id`);

--
-- قيود الجداول `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
