# Setup Instructions
You'll need to grant the application access to the ORDERS table within tpch_sf10 schema in snowflake_sample_data which is a default share available in every snowflake account.

Create a table in a different database in this account and materialize the required data:
```
-- create a databse and schema to hold the orders data
create database app_test;
create schema data;

-- CTAS the orders data from snowflake_sample_data into a table in a database created
create table app_test.data.orders as select * from snowflake_sample_data.tpch_sf10.orders;
```
 Please grant a reference to the orders table created above in a separate database from the privileges tab before clicking Launch app!