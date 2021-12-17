
SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000
SET FEEDBACK OFF;

Prompt ********************************************ADD ARTICLE*****************************************************


Prompt
Prompt ORDER NUMBER:
DEFINE order = &1
Prompt 

 
Prompt ARTICLE IDENTIFIER:
DEFINE article = &2
prompt

Prompt
Prompt QUANTITY:
DEFINE quantity = &3
Prompt

Prompt
Prompt SERVICES 
DEFINE service_id = &4
Prompt


BEGIN
    INSERT INTO order_item(order_number, article_id, item_id, service_id)
    VALUES
    (    &order, 
        &article,
        (SELECT COUNT(item_id) FROM order_item WHERE order_number = &order AND article_id = &article) + 1,
        CASE WHEN '&service_id' = (SELECT service_id FROM article_service WHERE article_id = &article AND service_id = '&service_id') THEN '&service_id'
        ELSE null END);
    INSERT INTO package_item (order_number, article_id,  service_id, package_id, quantity) VALUES (&order, &article, '&service_id', &order,  &quantity);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE package_item SET quantity = quantity +  &quantity WHERE order_number = &order AND article_id = &article AND  service_id = '&service_id';
END;
/


prompt
Prompt ORDER TITLE:
SELECT 
    TO_CHAR(&order, '0099') "ORDER NUMBER",
    name "CLIENT NAME"
FROM clients
WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order);


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
)
SELECT SUM((c1.quantity * (SELECT 
                            c2.price FROM cte2 c2 WHERE 
                            c2.article_id = c1.article_id)))
        +SUM(NVL(c3.service_price, 0)) TOTAL
FROM cte1 c1
LEFT OUTER JOIN cte3 c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id;

UNDEFINE order;
UNDEFINE article;
UNDEFINE quantity;
UNDEFINE service;

Prompt
COMMIT;



