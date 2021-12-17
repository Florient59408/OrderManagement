SET VERIFY OFF
SET LINESIZE 3000
SET PAGESIZE 1000

Prompt
Prompt***************************** INSTALLING ORDER BILLING SCHEMA *****************************
Prompt
--
-- create user
--

@./User/user

REM =======================================================
REM create ob schema objects
REM =======================================================

CONNECT ob/&pass@&connect_string
ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

--
-- create tables
--

@./Tables/tables

-- 
-- create index and constraints
--

@./Constraints/constraints

--
-- create procedural objects and sequences
--

@./Procedural_Objects/po_s

--
-- popluate tables
--

@./Datas/datas


Prompt
spool OFF;
