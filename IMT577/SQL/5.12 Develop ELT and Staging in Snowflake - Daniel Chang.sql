/************************************************
Name: Daniel Chang
Course: IMT 577
Instructor: Janak Rajani
5.12 Develop ELT and Staging in Snowflake
Date: 7/24/2022
************************************************/
create or replace file format CSV_SKIP_HEADER
type = 'CSV'
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
skip_header = 1;

use database "IMT577_DW_DANIEL_CHANG_M5";

/*************************
Create staging tables
*************************/

create or replace table stage_channel (
  channelid integer
  ,channelcategoryid integer
  ,channel varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_channelcategory (
  channelcategoryid integer
  ,channelcategory varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_customer (
  customerid varchar(255)
  ,subsegmentid integer
  ,firstname varchar(255)
  ,lastname varchar(255)
  ,gender varchar(255)
  ,emailaddress varchar(255)
  ,address varchar(255)
  ,city varchar(255)
  ,stateprovince varchar(255)
  ,country varchar(255)
  ,postalcode varchar(255)
  ,phonenumber varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_product (
  productid integer
  ,producttypeid integer
  ,product varchar(255)
  ,color varchar(255)
  ,style varchar(255)
  ,unitofmeasureid integer
  ,weight integer
  ,price float
  ,cost float
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
  ,wholesaleprice float
)
;

create or replace table stage_productcategory (
  productcategoryid integer
  ,productcategory varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_producttype (
  producttypeid integer
  ,productcategoryid integer
  ,producttype varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_reseller (
  resellerid varchar(255)
  ,contact varchar(255)
  ,emailaddress varchar(255)
  ,address varchar(255)
  ,city varchar(255)
  ,stateprovince varchar(255)
  ,country varchar(255)
  ,postalcode varchar(255)
  ,phonenumber varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
  ,resellername varchar(255)
)
;

create or replace table stage_salesdetail (
  salesdetailid integer
  ,salesheaderid integer
  ,productid integer
  ,salesquantity integer
  ,salesamount float
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_salesheader (
  salesheaderid integer
  ,date date
  ,channelid integer
  ,storeid integer
  ,customerid varchar(255)
  ,resellerid varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;

create or replace table stage_store (
  storeid integer
  ,subsegmentid integer
  ,storenumber integer
  ,storemanager varchar(255)
  ,address varchar(255)
  ,city varchar(255)
  ,stateprovince varchar(255)
  ,country varchar(255)
  ,postalcode varchar(255)
  ,phonenumber varchar(255)
  ,createddate datetime
  ,createdby varchar(255)
  ,modifieddate datetime
  ,modifiedby varchar(255)
)
;