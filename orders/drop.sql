SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CONNECT ob/&password_ob@&connect_string

DROP TABLE users     CASCADE CONSTRAINTS;
DROP TABLE employees   CASCADE CONSTRAINTS;
DROP TABLE shipping_class   CASCADE CONSTRAINTS;
DROP TABLE stores   CASCADE CONSTRAINTS;  
DROP TABLE services     CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;
DROP TABLE city   CASCADE CONSTRAINTS;
DROP TABLE locations        CASCADE CONSTRAINTS;
DROP TABLE address CASCADE CONSTRAINTS;
DROP TABLE clients   CASCADE CONSTRAINTS;
DROP TABLE articles   CASCADE CONSTRAINTS;  
DROP TABLE orders     CASCADE CONSTRAINTS;
DROP TABLE order_item CASCADE CONSTRAINTS;
DROP TABLE vouchers   CASCADE CONSTRAINTS;
DROP TABLE article_group        CASCADE CONSTRAINTS;
DROP TABLE warehouses CASCADE CONSTRAINTS;
DROP TABLE warehouse_article   CASCADE CONSTRAINTS;
DROP TABLE article_service   CASCADE CONSTRAINTS; 
DROP TABLE warranties   CASCADE CONSTRAINTS;
DROP TABLE installations   CASCADE CONSTRAINTS;  
DROP TABLE list_price     CASCADE CONSTRAINTS;
DROP TABLE packages        CASCADE CONSTRAINTS;
DROP TABLE package_item CASCADE CONSTRAINTS;
DROP TABLE group_voucher   CASCADE CONSTRAINTS;
DROP TABLE Sound_purchase   CASCADE CONSTRAINTS;
DROP TABLE Sound_purchase_client  CASCADE CONSTRAINTS;


DROP SEQUENCE order_number_seq;
DROP SEQUENCE client_id_seq;
DROP SEQUENCE warehouse_id_seq;
DROP SEQUENCE store_id_seq;
DROP SEQUENCE article_id_seq;
DROP SEQUENCE warranty_id_seq;
DROP SEQUENCE installation_id_seq;
DROP SEQUENCE employee_id_seq;
DROP SEQUENCE user_id_seq;
DROP SEQUENCE package_id_seq;
DROP SEQUENCE sound_purchase_id_seq;

COMMIT;