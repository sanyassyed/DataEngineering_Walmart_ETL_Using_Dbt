-------------------------------------
-- DATA LOADING
-------------------------------------

USE WAREHOUSE COMPUTE_WH;
CREATE DATABASE IF NOT EXISTS WALMART;
USE WALMART;

CREATE SCHEMA IF NOT EXISTS LAND;

---STORE
CREATE OR REPLACE TABLE LAND.store
(
	store_key	INTEGER,
	store_num	varchar(30),
	store_desc	varchar(150),
	addr	varchar(500),
	city	varchar(50),
	region varchar(100),
	cntry_cd	varchar(30),
	cntry_nm	varchar(150),
	postal_zip_cd	varchar(10),
	prov_state_desc	varchar(30),
	prov_state_cd	varchar(30),
    store_type_cd varchar(30),
    store_type_desc varchar(150),
	frnchs_flg	boolean,
	store_size numeric(19,3),
	market_key	integer,
	market_name	varchar(150),
    submarket_key	integer,
	submarket_name	varchar(150),
	latitude	NUMERIC(19, 6),
	longitude	NUMERIC(19, 6)
);



---CALENDAR
CREATE OR REPLACE TABLE LAND.calendar
(	
	cal_dt	date NOT NULL,
	cal_type_desc	varchar(20),
	day_of_wk_num	 varchar(30),
	day_of_wk_desc varchar,
	yr_num	integer,
	wk_num	integer,
	yr_wk_num	integer,
	mnth_num	integer,
	yr_mnth_num	integer,
	qtr_num	integer,
	yr_qtr_num	integer
);


----PRODUCT
CREATE OR REPLACE TABLE LAND.product 
(
	prod_key int ,
	prod_name varchar,
	vol NUMERIC (38,2),
	wgt NUMERIC (38,2),
	brand_name varchar, 
	status_code int,
	status_code_name varchar,
	category_key int,
	category_name varchar,
	subcategory_key int,
	subcategory_name varchar
);


-----SALES
CREATE OR REPLACE TABLE LAND.sales(
trans_id int,
prod_key int,
store_key int,
trans_dt date,
trans_time int,
sales_qty numeric(38,2),
sales_price numeric(38,2),
sales_amt NUMERIC(38,2),
discount numeric(38,2),
sales_cost numeric(38,2),
sales_mgrn numeric(38,2),
ship_cost numeric(38,2)
);


------- INVENTORY
CREATE OR REPLACE TABLE LAND.inventory (
cal_dt date,
store_key int,
prod_key int,
inventory_on_hand_qty NUMERIC(38,2),
inventory_on_order_qty NUMERIC(38,2),
out_of_stock_flg int,
waste_qty number(38,2),
promotion_flg boolean,
next_delivery_dt date
);

-- Data Load
-- Load data into the above tables from the csv's using the left click on the table & `Import Data`

-------------------------------------------------------
-- EDA & Data Load Check
-------------------------------------------------------
-- Priliminary EDA
USE DATABASE WALMART;
USE SCHEMA LAND;

SELECT * FROM LAND.INVENTORY
LIMIT 5;

SELECT
       store_key,
       prod_key,
       COUNT(cal_dt)
FROM inventory
GROUP BY 1, 2
ORDER BY 3 DESC, 1, 2;

SELECT *
FROM INVENTORY
WHERE store_key = 248 AND 
      prod_key = 381761
ORDER BY cal_dt asc;

SELECT COUNT(DISTINCT store_key) distinct_stores,
       COUNT(DISTINCT prod_key) distinct_prods
FROM INVENTORY;

SELECT COUNT(DISTINCT store_key) distinct_stores,
       COUNT(DISTINCT prod_key) distinct_prods
FROM SALES; -- 134 1212

SELECT p.prod_key
FROM product p
     LEFT JOIN sales s
     ON p.prod_key = s.prod_key
WHERE s.prod_key IS NULL; --481925 861429 72480

SELECT p.prod_key
FROM product p
     LEFT JOIN inventory s
     ON p.prod_key = s.prod_key
WHERE s.prod_key IS NULL; --481925 861429 72480

SELECT s.store_key
FROM store s
     LEFT JOIN sales sa
     ON s.store_key = sa.store_key
WHERE sa.store_key IS NULL; -- 17 stores have inventory data but no sales data i.e these 17 store had no sales

SELECT s.store_key
FROM store s
     LEFT JOIN inventory i
     ON s.store_key = i.store_key
WHERE i.store_key IS NULL; 

-- inventory of stores that have no sales recorded
WITH store_with_no_sales
AS
(
SELECT *
FROM inventory
WHERE store_key IN (SELECT DISTINCT s.store_key
FROM store s
     LEFT JOIN sales sa
     ON s.store_key = sa.store_key
WHERE sa.store_key IS NULL)
ORDER BY cal_dt,
         store_key,
         prod_key
)
SELECT store_key,
      prod_key,
      COUNT(cal_dt)
FROM store_with_no_sales
GROUP BY 1, 2
ORDER BY 3 DESC, 1,2;

-- Checking the inventory level of the product in the store where there have been no sales recorded.
-- Since the inventory is changing either the sales records are missing or the inventory is getting stolen

SELECT * FROM inventory
WHERE prod_key = 381761 AND store_key = 9004
ORDER BY cal_dt ASC;

-----------------------
-- DATA LOAD CHECK
------------------------
SELECT COUNT(*) total_records
FROM LAND.calendar; -- 10598

SELECT COUNT(*) total_records
FROM LAND.product; -- 1215

SELECT COUNT(*) total_records
FROM LAND.store; -- 151

SELECT COUNT(*) total_records
FROM LAND.inventory; -- 1192296

SELECT COUNT(*) total_records
FROM LAND.sales; -- 1062368

----------------------------
-- TEST SETUP
-----------------------------
-- Update the original dataset with the following scripts.
-- We are simulating data change in the following source tables
-- Sales - Adding 3 sale trnasactions
-- Inventory - Adding 5 inventory updates
-- Product - Updating two products and inserting one new product

-- Inserting new records in LAND.sales
INSERT INTO LAND.sales
VALUES
(302836,540260,3220,'2012-12-31',18,37.80,3.58,129.42,0.01,300.72,-150.37,5.47),
(312076,399912,3220,'2013-01-01',7,29.00,145.45,3773.59,0.02,3486.71,731.32,17.85),
(337584,135665,1104,'2013-01-02',18,11.00,41.32,447.09,0.09,365.40,89.03,8.66);

-- Inserting new records in LAND.inventory
INSERT INTO LAND.inventory
VALUES
('2012-12-31',1103,540260,26.46,75.60,1,0.00,'FALSE','2012-12-31'),
('2012-12-31',1103,904715,27.09,21.07,0,1.00,'FALSE','2012-12-31'),
('2013-01-01',1104,135665,11.00,14.30,1,0.00,'FALSE','2012-12-31'),
('2013-01-01',1104,200147,6.72,5.88,0,0.00,'TRUE','2012-12-31'),
('2013-01-02',1104,399912,7.83,46.98,1,1.00,'TRUE','2012-12-31');

-- Update & Insert in table LAND.product
UPDATE LAND.PRODUCT SET PROD_NAME='CHANGE-1' WHERE PROD_KEY=657768;
UPDATE LAND.PRODUCT SET PROD_NAME='CHANGE-2' WHERE PROD_KEY=293693;
INSERT INTO LAND.PRODUCT VALUES (999999,'ADD-1',2.22, 88.88, 'brand-999', 1, 'active', 4, 'category-4', 1, 'subcategory-1');

-- RUN THE codes in dml.sql script
-- MERGE INTO
SELECT * FROM LAND.PRODUCT WHERE PROD_KEY =  999999;

----------------------------
-- TEST
-----------------------------
-- Before Insert
-- Total records in ENTERPRISE.fact_daily_sales : 
SELECT COUNT(*) FROM ENTERPRISE.fact_daily_sales; --1192296
-- Total records in ENTERPRISE.weekly_daily_sales : 
SELECT COUNT(*) FROM ENTERPRISE.fact_weekly_sales; --1172364
-- Total unique products in ENTERPRISE.fact_daily_sales, dim_product & fact_weekly_sales :
SELECT COUNT(DISTINCT PROD_NATURAL_KEY) FROM ENTERPRISE.dim_product; --1215
SELECT COUNT(DISTINCT PROD_SK) FROM ENTERPRISE.fact_daily_sales; --1212
SELECT COUNT(DISTINCT PROD_SK) FROM ENTERPRISE.fact_weekly_sales; --1212
-- Total unique products in ENTERPRISE.fact_weekly_sales :
-- Total unique products in ENTERPRISE.dim_product :
SELECT min(date_sk), MAX(date_sk) FROM ENTERPRISE.fact_daily_sales; --20090101 20121230
SELECT * FROM ENTERPRISE.dim_product WHERE PROD_NATURAL_KEY=657768; --1 records

-- After Insert
-- Total records in ENTERPRISE.fact_daily_sales : 
SELECT COUNT(*) FROM ENTERPRISE.fact_daily_sales; --1192304
-- Total records in ENTERPRISE.weekly_daily_sales : 
SELECT COUNT(*) FROM ENTERPRISE.fact_weekly_sales; --1172371
-- Total unique products in ENTERPRISE.fact_daily_sales :
-- Total unique products in ENTERPRISE.fact_weekly_sales :
-- Total unique products in ENTERPRISE.dim_product :
SELECT COUNT(DISTINCT PROD_NATURAL_KEY) FROM ENTERPRISE.dim_product; --1216
SELECT COUNT(DISTINCT PROD_SK) FROM ENTERPRISE.fact_daily_sales; --1212
SELECT COUNT(DISTINCT PROD_SK) FROM ENTERPRISE.fact_weekly_sales; --1212

SELECT min(date_sk), MAX(date_sk) FROM ENTERPRISE.fact_daily_sales; --20090101 20130102
SELECT * FROM ENTERPRISE.dim_product WHERE PROD_NATURAL_KEY=657768; --2 records