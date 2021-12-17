SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000
SET FEEDBACK OFF
SET SERVEROUTPUT ON

prompt
Prompt ********************************************ORDER CREATION*****************************************************
prompt

prompt
Prompt USER:
DEFINE user = &1
prompt

Prompt CLIENT:
DEFINE client = &1
prompt


Prompt SOTRE IDENTIFIER:
DEFINE store = &3
prompt

Prompt BILLING ADDRESS:
DEFINE billing = &4
prompt

Prompt DELIVERY ADDRESS:
DEFINE delivery = &5
Prompt

INSERT INTO orders(creation_user, client_id, billing_address, store_id) 
    VALUES (
        &user, 
        &client, 
        '&billing', 
        &store);
INSERT INTO packages(order_number, delivery_address, delivery_mode, statute) 
    VALUES (
            order_number_seq.currval,
            '&delivery',
            CASE WHEN '&delivery' LIKE '%ST%' THEN 'agency'
            ELSE 'home' END,
            'not yet');

SELECT 
        TO_CHAR(order_number_seq.currval, '0099') "ORDER NUMBER",
        name "CLIENT NAME"
        INTO :v_name, :v_order_number
    FROM clients
    WHERE client_id = &client;



UNDEFINE usert;
UNDEFINE mode;
UNDEFINE store;
UNDEFINE billing;
UNDEFINE delivery;
UNDEFINE delivery_mode;
UNDEFINE client;

Prompt
COMMIT;