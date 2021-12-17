SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000
SET FEEDBACK OFF;


prompt
Prompt ********************************************APPLY VOUCHER*****************************************************
prompt

Prompt
Prompt ORDER NUMBER:
DEFINE order = &1 
Prompt

Prompt
Prompt VOUCHER IDENTIFIER:
DEFINE voucher = &2
Prompt


update orders set voucher_id = CASE WHEN EXISTS(
    SELECT * FROM order_item o
    LEFT OUTER JOIN articles a ON a.article_id = o.article_id 
    RIGHT OUTER JOIN article_group ag ON ag.group_id = a.group_id
    LEFT OUTER JOIN group_voucher gv ON gv.group_id = ag.group_id AND gv.voucher_id = &voucher 
    WHERE gv.end_date > SYSDATE AND o.order_number = &order 
) THEN &voucher else NULL END WHERE order_number = &order;


WITH cte1
AS(
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders o ON TO_CHAR(o.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND o.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id
    WHERE oi.order_number = &order),
cte2
AS(
    SELECT  DISTINCT(oi.article_id),
        CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= oi.article_id )
        THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= oi.article_id )
        ELSE (SELECT price FROM articles WHERE article_id = oi.article_id) END price
    FROM order_item oi
),
cte3
AS(
    SELECT oi.order_number, oi.article_id,
    CASE WHEN s.type = 'percentage' THEN s.percentage * c2.price
    ELSE s.amount  END * 
    (SELECT c1.quantity FROM cte1 c1 WHERE c1.order_number = oi.order_number AND c1.article_id = oi.article_id) service_price
    FROM order_item oi
    LEFT OUTER JOIN services s ON oi.service_id = s.service_id
    LEFT OUTER JOIN cte2 c2 ON c2.article_id = oi.article_id
    WHERE oi.order_number = &order
),
cte4
AS(
    SELECT SUM((c1.quantity * (SELECT 
                            c2.price FROM cte2 c2 WHERE 
                            c2.article_id = c1.article_id)))
        +SUM(NVL(c3.service_price, 0)) TOTAL 
    FROM cte1 c1
    LEFT OUTER JOIN cte3 c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id
)
SELECT (SELECT c4.total FROM  cte4 c4 ) ||' (-' ||
    CASE WHEN v.type = 'percentage' THEN v.percentage * (SELECT c4.total FROM  cte4 c4 )
    ELSE v.amount  END || ' )' "BILLING AMOUNT"
    FROM orders o
    LEFT OUTER JOIN vouchers v ON v.voucher_id = o.voucher_id 
    WHERE o.order_number = &order;

UNDEFINE order;
UNDEFINE voucher;

Prompt

COMMIT;