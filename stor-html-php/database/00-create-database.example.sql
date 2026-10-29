-- Run as MySQL owner. Replace passwords LOCALLY before execution.
CREATE DATABASE IF NOT EXISTS stor_html CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'stor_html_setup'@'localhost' IDENTIFIED BY 'REPLACE_SETUP_PASSWORD';
GRANT CREATE, ALTER, INDEX, REFERENCES, CREATE VIEW, SELECT, INSERT, UPDATE, DELETE ON stor_html.* TO 'stor_html_setup'@'localhost';
CREATE USER 'stor_html_app'@'localhost' IDENTIFIED BY 'REPLACE_DIFFERENT_APP_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE ON stor_html.* TO 'stor_html_app'@'localhost';
