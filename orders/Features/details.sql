SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000
SET FEEDBACK OFF;


prompt
Prompt ********************************************ORDER DETAILS*****************************************************
prompt



Prompt
Prompt ORDER NUMBER:
DEFINE order = &1
Prompt

Prompt

SELECT 
    TO_CHAR(&order, '0099') "ORDER NUMBER",
    name "CLIENT NAME"
FROM clients
WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order);

prompt

SELECT     
    oi.article_id "ARTICLE IDENTIFIER",
    (SELECT a.article_name FROM articles a WHERE a.article_id = oi. article_id ) "ARTICLE NAME",
    (SELECT p.quantity FROM package_item p WHERE p.order_number = oi.order_number AND p.article_id = oi.article_id AND p.item_id = oi.item_id) "QUANTITY",
    (SELECT
        DISTINCT(
            CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
            THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
            ELSE (SELECT price FROM articles WHERE article_id = ooi.article_id) END
        )
    FROM order_item ooi
    WHERE ooi.article_id = oi.article_id) + 
    NVL((   SELECT CASE WHEN s.type = 'percentage' THEN s.percentage *  
                                                                        (SELECT
                                                                            DISTINCT(
                                                                                CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
                                                                                THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
                                                                                ELSE (SELECT price FROM articles WHERE article_id = ooi.article_id) END
                                                                            )
                                                                        FROM order_item ooi
                                                                        WHERE ooi.article_id = oi.article_id)
        ELSE s.amount  END
        FROM services s
        WHERE  s.service_id = oi.service_id), 0) "UNITARY PRICE",
    (SELECT p.quantity FROM package_item p WHERE p.order_number = oi.order_number AND p.article_id = oi.article_id AND p.item_id = oi.item_id) * ((SELECT
        DISTINCT(
            CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
            THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
            ELSE (SELECT price FROM articles WHERE article_id = ooi.article_id) END
        )
    FROM order_item ooi
    WHERE ooi.article_id = oi.article_id) + 
    NVL((   SELECT CASE WHEN s.type = 'percentage' THEN s.percentage *  
                                                                        (SELECT
                                                                            DISTINCT(
                                                                                CASE WHEN EXISTS(SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
                                                                                THEN (SELECT price FROM list_price WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND article_id= ooi.article_id )
                                                                                ELSE (SELECT price FROM articles WHERE article_id = ooi.article_id) END
                                                                            )
                                                                        FROM order_item ooi
                                                                        WHERE ooi.article_id = oi.article_id)
        ELSE s.amount  END
        FROM services s
        WHERE  s.service_id = oi.service_id), 0)) "TOTAL PRICE",
    (SELECT a.article_description FROM articles a WHERE a.article_id = oi. article_id ) "DESCRIPTION"
FROM orders o
LEFT OUTER JOIN order_item oi ON oi.order_number = o.order_number
WHERE o.order_number = &order
ORDER BY oi.article_id ASC;

--TOTAL AMOUNT FOR CURRENT ORDER

prompt

WITH cte1
AS(
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders o ON TO_CHAR(o.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND o.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id AND pi.item_id = oi.item_id
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
Prompt
COMMIT;