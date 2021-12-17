SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000
SET FEEDBACK OFF;

prompt
Prompt ********************************************USE SOUND PURCHASE*****************************************************
prompt


Prompt
Prompt ORDER NUMBER:
DEFINE order = &1 

SELECT 
    DISTINCT(spc.sound_purchase_id) "SOUND PURCHASE NUMBER",
    ag.title "GROUP",
    a.article_name "ARTICLE",
    spc.amount "CURRENT AMOUNT",
    o.order_number
FROM orders o
RIGHT OUTER JOIN order_item oi ON oi.order_number = o.order_number
RIGHT OUTER JOIN articles a ON a.article_id = oi.article_id
RIGHT OUTER JOIN article_group ag ON ag.group_id = a.group_id
RIGHT OUTER JOIN sound_purchase sp ON sp.group_id = ag.group_id
RIGHT OUTER JOIN sound_purchase_client spc ON spc.sound_purchase_id = sp.sound_purchase_id AND spc.client_id = (SELECT client_id FROM orders WHERE order_number = &order)
WHERE o.order_number = &order;

Prompt
Prompt SELECT THE SOUND PURCHASE TO USE:
DEFINE sp = &2


WITH cte1
AS(
    SELECT pi.quantity, pi.order_number, pi.article_id
    FROM order_item oi    
    LEFT OUTER JOIN orders o ON TO_CHAR(o.order_date, 'DD-Month-YYYY') = TO_CHAR(SYSDATE, 'DD-Month-YYYY') AND o.order_number = oi.order_number
    RIGHT OUTER JOIN package_item pi ON pi.order_number = oi.order_number   AND pi.article_id = oi.article_id
    WHERE oi.order_number = &order AND pi.item_id = oi.item_id),
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
    SELECT 
        ag.group_id,
        SUM((c1.quantity * (SELECT 
                            c2.price FROM cte2 c2 WHERE 
                            c2.article_id = c1.article_id)))
        +SUM(NVL(c3.service_price, 0)) TOTAL 
    FROM cte1 c1
    LEFT OUTER JOIN cte3 c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id
    LEFT OUTER JOIN articles a ON a.article_id = c3.article_id
    LEFT OUTER JOIN article_group ag ON ag.group_id = a.group_id
    GROUP BY ag.group_id
),
cte5
AS(
    SELECT 
        CASE WHEN c4.total - NVL(spc.amount, 0) < 0 THEN 0  
                ELSE c4.total - NVL(spc.amount, 0) END  result
    FROM cte4 c4
    LEFT OUTER JOIN sound_purchase sp ON sp.group_id = c4.group_id
    LEFT OUTER JOIN sound_purchase_client spc ON spc.sound_purchase_id = sp.sound_purchase_id
)
SELECT 
    SUM(NVL(c5.result, 0))"FINALL AMOUNT TO PAY"
FROM cte5 c5;

Prompt
Prompt *****UDATING SOUND PURCHASE AMOUNT .....
Prompt

UPDATE sound_purchase_client
SET amount = CASE
                WHEN    (WITH cte1 
                        AS (SELECT oi.article_id, ag.group_id FROM order_item oi
                            LEFT OUTER JOIN articles a ON a.article_id = oi.article_id
                            LEFT OUTER JOIN article_group ag ON ag.group_id = a.group_id
                            WHERE oi.order_number = &order
                        ) 
                        SELECT SUM(NVL(spc.amount, 0))
                        FROM sound_purchase sp
                        LEFT OUTER JOIN cte1 c1 ON c1.group_id = sp.group_id
                        RIGHT OUTER JOIN Sound_purchase_client spc ON spc.sound_purchase_id= sp.sound_purchase_id
                        WHERE spc.client_id = (SELECT client_id FROM orders WHERE order_number = &order))>=
                        (
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
                        ),
                        cte4
                        AS(
                            SELECT 
                                ag.group_id,
                                SUM((c1.quantity * (SELECT 
                                                    c2.price FROM cte2 c2 WHERE 
                                                    c2.article_id = c1.article_id)))
                                +SUM(NVL(c3.service_price, 0)) TOTAL 
                            FROM cte1 c1
                            LEFT OUTER JOIN cte3 c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id
                            LEFT OUTER JOIN articles a ON a.article_id = c3.article_id
                            LEFT OUTER JOIN article_group ag ON ag.group_id = a.group_id
                            GROUP BY ag.group_id
                        )
                        SELECT SUM(DISTINCT(NVL(c4.total, 0)))
                        FROM cte4 c4
                        RIGHT OUTER JOIN sound_purchase sp ON sp.group_id = c4.group_id
                        RIGHT OUTER JOIN sound_purchase_client spc ON spc.sound_purchase_id = sp.sound_purchase_id
                        )
                    THEN 
                        (WITH cte1 
                        AS (SELECT oi.article_id, ag.group_id FROM order_item oi
                            LEFT OUTER JOIN articles a ON a.article_id = oi.article_id
                            LEFT OUTER JOIN article_group ag ON ag.group_id = a.group_id
                            WHERE oi.order_number = &order
                        ) 
                        SELECT SUM(NVL(spc.amount, 0))
                        FROM sound_purchase sp
                        LEFT OUTER JOIN cte1 c1 ON c1.group_id = sp.group_id
                        RIGHT OUTER JOIN Sound_purchase_client spc ON spc.sound_purchase_id= sp.sound_purchase_id
                        WHERE spc.client_id = (SELECT client_id FROM orders WHERE order_number = &order))-
                        (
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
                        ),
                        cte4
                        AS(
                            SELECT 
                                ag.group_id,
                                SUM((c1.quantity * (SELECT 
                                                    c2.price FROM cte2 c2 WHERE 
                                                    c2.article_id = c1.article_id)))
                                +SUM(NVL(c3.service_price, 0)) TOTAL 
                            FROM cte1 c1
                            LEFT OUTER JOIN cte3 c3 ON c3.order_number = c1.order_number AND c3.article_id = c1.article_id
                            LEFT OUTER JOIN articles a ON a.article_id = c3.article_id
                            LEFT OUTER JOIN article_group ag ON ag.group_id = a.group_id
                            GROUP BY ag.group_id
                        )
                        SELECT SUM(DISTINCT(NVL(c4.total, 0)))
                        FROM cte4 c4
                        RIGHT OUTER JOIN sound_purchase sp ON sp.group_id = c4.group_id
                        RIGHT OUTER JOIN sound_purchase_client spc ON spc.sound_purchase_id = sp.sound_purchase_id
                        )
                        ELSE 0 END
WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order) AND sound_purchase_id = '&sp';

SELECT sound_purchase_id "SOUND PURCHASE NUMBER", amount "CURRENT AMOUNT"
FROM sound_purchase_client 
WHERE client_id = (SELECT client_id FROM orders WHERE order_number = &order)
AND sound_purchase_id = '&sp';


UNDEFINE order
UNDEFINE sp

Prompt
COMMIT;