# Readme.md
You'll need to grant the application access to the ORDERS table within tpch_sf10 schema in snowflake_sample_data 
* Create a table in a different database in this account and materialize the required data:
```
create database app_test;
create schema data;
create table app_test.data.orders as select * from snowflake_sample_data.tpch_sf10.orders;
select * from app_test.data.orders;
```
* Please grant a reference to the orders table from the privileges section for the app page in Snowsight