create table silver.crm_cust_info (like bronze.crm_cust_info);
create table silver.crm_prd_info (like bronze.crm_prd_info);
create table silver.crm_sales_details (like bronze.crm_sales_details);
create table silver.erp_cust_az12 (like bronze.erp_cust_az12);
create table silver.erp_loc_a101 (like bronze.erp_loc_a101);
create table silver.erp_px_cat_g1v2 (like bronze.erp_px_cat_g1v2);

alter table silver.crm_cust_info add column dwh_create_date timestamp default now();
alter table silver.crm_prd_info add column dwh_create_date timestamp default now();
alter table silver.crm_sales_details add column dwh_create_date timestamp default now();
alter table silver.erp_cust_az12 add column dwh_create_date timestamp default now();
alter table silver.erp_loc_a101 add column dwh_create_date timestamp default now();
alter table silver.erp_px_cat_g1v2 add column dwh_create_date timestamp default now();

-- crm_prd_info
  alter table silver.crm_prd_info add column cat_id varchar(50);
  alter table silver.crm_prd_info alter column prd_start_dt type date;
  alter table silver.crm_prd_info alter column prd_end_dt type date;

-- crm_sales_details
  alter table silver.crm_sales_details drop column sls_order_dt;
  alter table silver.crm_sales_details add column sls_order_dt date;
  alter table silver.crm_sales_details drop column sls_ship_dt;
  alter table silver.crm_sales_details add column sls_ship_dt date;
  alter table silver.crm_sales_details drop column sls_due_dt;
  alter table silver.crm_sales_details add column sls_due_dt date;

-- Checking quality of data in bronze layer
-- Checking for Duplicates and null in primary key

-- crm_cust_info
  -- Checking for Duplicates and null in primary key
    select cst_id, count(*) from bronze.crm_cust_info
    group by cst_id
    having count(*) > 1 or cst_id is null;
    select cst_id from (select *, row_number() over (partition by cst_id order by cst_create_date desc) as flag_last from bronze.crm_cust_info) t where flag_last !=1 ;
  -- Checking for unwanted spaces
    select cst_firstname from bronze.crm_cust_info
    where cst_firstname != trim(cst_firstname);
    select cst_lastname from bronze.crm_cust_info
    where cst_lastname != trim(cst_lastname);
    select cst_marital_status from bronze.crm_cust_info
    where cst_marital_status != trim(cst_marital_status);
    select cst_gndr from bronze.crm_cust_info
    where cst_gndr != trim(cst_gndr);
    -- Validation
    select cst_id, count(*) from silver.crm_cust_info
    group by cst_id
    having count(*) > 1 or cst_id is null;

-- crm_prd_info
  select prd_id, count(*) from bronze.crm_prd_info group by prd_id having count(*) > 1 or prd_id is null;
  select prd_id, replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
  substring(prd_key, 7, length(prd_key)) as prd_key,
  prd_nm, coalesce(prd_cost,0) as prd_cost, 
  case when upper(trim(prd_line)) = 'M' then 'Mountain'
   when upper(trim(prd_line)) = 'R' then 'Road'
    when upper(trim(prd_line)) = 'S' then 'Other Sales'
    when upper(trim(prd_line)) = 'T' then 'Touring'
    else 'N/A' end as prd_line, 
    cast(prd_start_dt as date) as prd_start_dt,
    cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) - interval '1 day' as date) as prd_end_dt
  from bronze.crm_prd_info;
-- crm_sales_details

-- erp_cust_az12
  select distinct gen from (select case when upper(trim(gen)) = 'F' then 'Female'
    when  upper(trim(gen))= 'M' then 'Male'
    when  upper(trim(gen)) = '' or  upper(trim(gen)) is null then 'N/A'
    else trim(gen) end as gen
  from silver.erp_cust_az12);

-- erp_loc_a101
  select distinct cntry from (
    select 
      case when cntry is null or trim(cntry) = '' then 'N/A' 
      when cntry like 'US%' then 'United States' 
      when cntry = 'DE' then 'Denmark'
      else trim(cntry) end cntry from bronze.erp_loc_a101);

-- erp_px_cat_g1v2
