SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000
SET FEEDBACK OFF;

prompt
Prompt ********************************************ORDER LIST*****************************************************
prompt

SELECT
o.order_number "ORDER NUMBER",
o.order_date "ORDER DATE",
o.creation_user "ORDER AUTHOR",
(SELECT u.user_name FROM users u WHERE u.user_id = o.creation_user) "AUTHOR NAME",
(SELECT COUNT(order_number) FROM order_item WHERE order_number = o.order_number) "ITEMS NUMBER",
o.billing_address "BILLING ADDRESS",
( SELECT (SELECT c4.total FROM  (
    SELECT SUM((c1.quantity * (SELECT 
                            c2.price FROM (
    SELECT  DISTINCT(oi.article_id),
        CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        ELSE (SELECT price FROM articles WHERE article_id = oi.article_id) END price
    FROM order_item oi
    ) c2 WHERE 
                            c2.article_id = c1.article_id)))
        +SUM(NVL(c3.service_price, 0)) TOTAL 
    FROM (
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders oo ON TO_CHAR(oo.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND oo.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id
    WHERE oi.order_number = o.order_number
    ) c1
    LEFT OUTER JOIN (
    SELECT oi.order_number, oi.article_id,
    CASE WHEN s.type = 'percentage' THEN s.percentage * c2.price
    ELSE s.amount  END * 
    (SELECT c1.quantity FROM (
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders oo ON TO_CHAR(oo.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND oo.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id
    WHERE oi.order_number = o.order_number
    ) c1 WHERE c1.order_number = oi.order_number AND c1.article_id = oi.article_id) service_price
    FROM order_item oi
    LEFT OUTER JOIN services s ON oi.service_id = s.service_id
    LEFT OUTER JOIN (
    SELECT  DISTINCT(oi.article_id),
        CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        ELSE (SELECT price FROM articles WHERE article_id = oi.article_id) END price
    FROM order_item oi
    ) c2 ON c2.article_id = oi.article_id
    WHERE oi.order_number = o.order_number
    ) c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id
    ) c4 ) ||' (-' ||
    CASE WHEN v.type = 'percentage' THEN v.percentage * (SELECT c4.total FROM  (
    SELECT SUM((c1.quantity * (SELECT 
                            c2.price FROM (
    SELECT  DISTINCT(oi.article_id),
        CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        ELSE (SELECT price FROM articles WHERE article_id = oi.article_id) END price
    FROM order_item oi
    ) c2 WHERE 
                            c2.article_id = c1.article_id)))
        +SUM(NVL(c3.service_price, 0)) TOTAL 
    FROM (
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders oo ON TO_CHAR(oo.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND oo.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id
    WHERE oi.order_number = o.order_number
    ) c1
    LEFT OUTER JOIN (
    SELECT oi.order_number, oi.article_id,
    CASE WHEN s.type = 'percentage' THEN s.percentage * c2.price
    ELSE s.amount  END * 
    (SELECT c1.quantity FROM (
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders oo ON TO_CHAR(oo.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND oo.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id
    WHERE oi.order_number = o.order_number
    ) c1 WHERE c1.order_number = oi.order_number AND c1.article_id = oi.article_id) service_price
    FROM order_item oi
    LEFT OUTER JOIN services s ON oi.service_id = s.service_id
    LEFT OUTER JOIN (
    SELECT  DISTINCT(oi.article_id),
        CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = o.order_number) AND article_id= oi.article_id )
        ELSE (SELECT price FROM articles WHERE article_id = oi.article_id) END price
    FROM order_item oi
    ) c2 ON c2.article_id = oi.article_id
    WHERE oi.order_number = o.order_number
    ) c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id
    ) c4 )
    ELSE v.amount  END || ' )' "BILLING AMOUNT"
    FROM orders oo
    LEFT OUTER JOIN vouchers v ON v.voucher_id = oo.voucher_id 
    WHERE oo.order_number = o.order_number
) "AMOUNT AND VOUCHER"
FROM orders o
LEFT OUTER JOIN Vouchers v on v.voucher_id = o.voucher_id
ORDER BY o.order_date ASC;
Prompt