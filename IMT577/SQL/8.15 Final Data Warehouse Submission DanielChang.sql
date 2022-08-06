/************************************************
Course: IMT 577
Instructor: Janak Rajani
8.15 Final Data Warehouse Submission 
Date: 8/14/2022
************************************************/

/***************************
Create "pass-through" views
***************************/

select dimproductid
      ,productid 
      ,producttypeid
      ,productcategoryid
      ,productname 
      ,producttype 
      ,productcategory
      ,productretailprice
      ,productwholesaleprice
      ,productcost 
      ,productretailprofit
      ,productwholesaleunitprofit
      ,productprofitmarginunitpercent
 from dim_product
;

select dimstoreid
      ,dimlocationid 
      ,sourcestoreid 
      ,storename 
      ,storenumber
      ,storemanager 
from dim_store
;

select dimresellerid 
      ,dimlocationid 
      ,resellerid 
      ,resellername
      ,contactname 
      ,phonenumber
      ,email 
from dim_reseller
;

select dimcustomerid
      ,dimlocationid 
      ,customerid 
      ,customerfullname
      ,customerfirstname
      ,customerlastname 
      ,customergender 
from dim_customer
;

select dimchannelid 
      ,channelid 
      ,channelcategoryid
      ,channelname 
      ,channelcategory
from dim_channel
;

select dimlocationid
      ,locationid 
      ,address 
      ,city 
      ,postalcode
      ,stateprovince
      ,country 
from dim_location
;

select date_pkey
      ,date	
      ,full_date_desc
      ,day_num_in_week
      ,day_num_in_month
      ,day_num_in_year	
      ,day_name		
      ,day_abbrev		
      ,weekday_ind		
      ,us_holiday_ind	
      ,uw_holiday_ind  
      ,month_end_ind	
      ,week_begin_date_nkey
      ,week_begin_date		
      ,week_end_date_nkey	
      ,week_end_date		
      ,week_num_in_year	
      ,month_name			
      ,month_abbrev		
      ,month_num_in_year	
      ,yearmonth			
      ,quarter				
      ,yearquarter			
      ,year				
      ,fiscal_week_num		
      ,fiscal_month_num	
      ,fiscal_yearmonth	
      ,fiscal_quarter		
      ,fiscal_yearquarter	
      ,fiscal_halfyear		
      ,fiscal_year			
      ,sql_timestamp		
      ,current_row_ind		
      ,effective_date		
      ,expiration_date		
from dim_date
;

select dimproductid 
    ,dimstoreid 
    ,dimresellerid
    ,dimcustomerid
    ,dimchannelid 
    ,dimsaledateid
    ,dimlocationid
    ,salesheaderid
    ,salesdetailid
    ,saleamount 
    ,salequantity
    ,saleunitprice
    ,saleextendedcost
    ,saletotalprofit 
from fact_salesactual
;

select dimstoreid
    ,dimresellerid
    ,dimchannelid 
    ,dimtargetdateid
    ,salestargetamount
from fact_srcsalestarget
;

select dimproductid 
    ,dimtargetdateid 
    ,producttargetsalesquantity
from fact_productsalestarget
;
/***************************
Create views
***************************/

-- View for monthly sale performance of each store
with monthly_sale_performance as (
    select date_trunc(month, dd.date) as month
        ,ds.storename
        ,sum(fsa.saleamount) as monthly_sale_amount
    from fact_salesactual fsa
        join dim_store ds on ds.dimstoreid = fsa.dimstoreid
        join dim_date dd on fsa.dimsaledateid = dd.date_pkey
    where ds.storename in ('Store Number 5', 'Store Number 8')
    group by month
        ,ds.storename
)

,monthly_sale_target as (
    select date_trunc(month, dd.date) as month 
        ,ds.storename 
        ,sum(fst.salestargetamount) as monthly_sales_target_amount -- different each month because some months have different # days
    from fact_srcsalestarget fst
        join dim_store ds on fst.dimstoreid = ds.dimstoreid
        join dim_date dd on fst.dimtargetdateid = dd.date_pkey
    where ds.storename in ('Store Number 5', 'Store Number 8')
    group by month 
        ,ds.storename
)

select mp.month 
    ,mp.storename
    ,mp.monthly_sale_amount
    ,mt.monthly_sales_target_amount
    ,mp.monthly_sale_amount - mt.monthly_sales_target_amount as difference
    ,mp.monthly_sale_amount / mt.monthly_sales_target_amount as pct
    ,case when difference > 0 then true else false end as met_sales_target
from monthly_sale_performance mp 
    join monthly_sale_target mt on mp.month = mt.month 
        and mp.storename = mt.storename
order by mp.month 
    ,mp.storename
; 

-- View for annual sales performance of Stores 5 & 8
with sales as (
    select year(dd.date) as year 
        ,ds.storename
        ,sum(fsa.saleamount) as saleamount 
        ,sum(fsa.saleextendedcost) as cost 
        ,sum(fsa.saletotalprofit) as profit
    from fact_salesactual fsa 
        join dim_store ds on fsa.dimstoreid = ds.dimstoreid
        join dim_date dd on fsa.dimsaledateid = dd.date_pkey
    where ds.storename in ('Store Number 5', 'Store Number 8')
    group by year(dd.date)
        ,ds.storename 
)

,target as (
    select year(dd.date) as year 
        ,ds.storename
        ,sum(salestargetamount) as salestargetamount
    from fact_srcsalestarget fst 
        join dim_store ds on fst.dimstoreid = ds.dimstoreid
        join dim_date dd on fst.dimtargetdateid = dd.date_pkey
    where ds.storename in ('Store Number 5', 'Store Number 8')
    group by year(dd.date)
        ,ds.storename
)

select s.year
    ,s.storename
    ,s.saleamount
    ,t.salestargetamount
    ,s.saleamount / t.salestargetamount as pct
    ,s.cost
    ,s.profit
from sales s 
    join target t on s.year = t.year
        and s.storename = t.storename
order by s.year
    ,s.storename
;

-- View for product sales of each store
with top_ten_margin as (
    select productname 
        ,productprofitmarginunitpercent
    from dim_product
    order by productprofitmarginunitpercent desc 
    limit 10
)

select date_trunc(year, dd.date) as year
    ,ds.storename
    ,dp.productname
    ,count(dp.productname) as saleqty
    ,dp.productretailprofit
    ,dp.productwholesaleunitprofit
    ,dp.productprofitmarginunitpercent
    ,case when ttm.productprofitmarginunitpercent is not null then true end as top_ten
from fact_salesactual fsa
    join dim_store ds on ds.dimstoreid = fsa.dimstoreid
    join dim_date dd on fsa.dimsaledateid = dd.date_pkey
    join dim_product dp on fsa.dimproductid = dp.dimproductid
    left join top_ten_margin ttm on dp.productname = ttm.productname
where ds.storename in ('Store Number 5', 'Store Number 8')
group by date_trunc(year, dd.date)
    ,ds.storename
    ,dp.productname
    ,dp.productretailprofit
    ,dp.productwholesaleunitprofit
    ,dp.productprofitmarginunitpercent
    ,top_ten
order by saleqty desc
;

-- View store performance by product type, specifically at casual clothing
select date_trunc(year, dd.date) as year 
    ,ds.storename 
    ,dp.producttype
    ,count(dp.producttype) as saleqty
from fact_salesactual fsa 
    join dim_store ds on ds.dimstoreid = fsa.dimstoreid
    join dim_date dd on fsa.dimsaledateid = dd.date_pkey
    join dim_product dp on fsa.dimproductid = dp.dimproductid
where ds.storename in ('Store Number 5', 'Store Number 8')
    and producttype ilike '%casual%'
group by date_trunc(year, dd.date)
    ,ds.storename
    ,dp.producttype
order by saleqty desc
;

-- View sales performance by day of the week
select ds.storename
    ,dd.day_name
    ,dd.day_num_in_week
    ,sum(fsa.saleamount) as saleamount 
from fact_salesactual fsa 
    join dim_store ds on fsa.dimstoreid = ds.dimstoreid
    join dim_date dd on fsa.dimsaledateid = dd.date_pkey
where ds.storename in ('Store Number 5', 'Store Number 8')
group by ds.storename 
    ,dd.day_name
    ,dd.day_num_in_week
order by dd.day_num_in_week
    ,ds.storename
;

-- View for comparative analysis between lone state stores and multi-location stores
with location_setup as (
    with dup_locations as (
        select dl.stateprovince
            ,count(*) as cnt 
        from dim_location dl 
            join dim_store ds on dl.dimlocationid = ds.dimlocationid
        group by dl.stateprovince
    )

    ,lone_state_stores as (
        select dl.dimlocationid
            ,ds.dimstoreid
            ,'lone' as storetype
        from dim_location dl
            join dim_store ds on dl.dimlocationid = ds.dimlocationid
        where dl.stateprovince in (select stateprovince from dup_locations where cnt = 1)
    )

    ,multi_location_states as (
        select dl.dimlocationid
            ,ds.dimstoreid
            ,'multi' as storetype
        from dim_location dl
            join dim_store ds on dl.dimlocationid = ds.dimlocationid
        where stateprovince in (select stateprovince from dup_locations where cnt > 1)
    )
    
    select * 
    from lone_state_stores
    
    union 
    
    select * 
    from multi_location_states
)

,sales as (
    select year(dd.date) as year 
        ,ls.storetype
        ,sum(fsa.saleamount) as saleamount 
        ,sum(fsa.saleextendedcost) as cost 
        ,sum(fsa.saletotalprofit) as profit
    from fact_salesactual fsa 
        join location_setup ls on fsa.dimlocationid = ls.dimlocationid 
        join dim_date dd on fsa.dimsaledateid = dd.date_pkey
    group by year(dd.date)
        ,ls.storetype
)

,target as (
    select year(dd.date) as year 
        ,ls.storetype
        ,sum(salestargetamount) as salestargetamount
    from fact_srcsalestarget fst 
        join location_setup ls on fst.dimstoreid = ls.dimstoreid 
        join dim_date dd on fst.dimtargetdateid = dd.date_pkey
    group by year(dd.date)
        ,ls.storetype
)

select s.year
    ,s.storetype
    ,s.saleamount
    ,t.salestargetamount
    ,s.saleamount / t.salestargetamount as pct
    ,s.cost
    ,s.profit
from sales s 
    join target t on s.year = t.year 
        and s.storetype = t.storetype
; 