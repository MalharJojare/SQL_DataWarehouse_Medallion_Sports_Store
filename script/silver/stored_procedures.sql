-- Checking quality of data in bronze layer
-- Checking for Duplicates and null in primary key

create or replace procedure silver.clean_silver()
language plpgsql    
as $$
begin
  truncate silver.crm_cust_info;
  truncate silver.crm_prd_info;
  truncate silver.crm_sales_details;
  truncate silver.erp_cust_az12;
  truncate silver.erp_loc_a101;
  truncate silver.erp_px_cat_g1v2;
commit;
end;$$;
call silver.clean_silver();
create or replace procedure silver.load_silver()
language plpgsql    
as $$
begin
    -- Combining the queries
    insert into silver.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) 
    select cst_id, cst_key, trim(cst_firstname) as cst_firstname, trim(cst_lastname) as cst_lastname,
      case 
        when upper(trim(cst_marital_status)) = 'S' then 'Single' 
        when upper(trim(cst_marital_status)) = 'S' then 'Married'
        else 'N/A' end cst_marital_status, 
      case 
        when upper(trim(cst_gndr)) ='F' then 'Female' 
        when upper(trim(cst_gndr)) = 'M' then 'Male' 
        else 'N/A' end cst_gndr, 
      cst_create_date
    from (select *, row_number() over (partition by cst_id order by cst_create_date desc) as flag_last from bronze.crm_cust_info where cst_id is not null) t where flag_last =1 ;
  
  -- crm_prd_info
  insert into silver.crm_prd_info(prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
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
  insert into silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
  select sls_ord_num, sls_prd_key, sls_cust_id,
    case when sls_order_dt = 0 or length(sls_order_dt::text) != 8 then null else
    cast(concat(substring(cast(sls_order_dt as varchar),1, 4), '-', substring(cast(sls_order_dt as varchar),5, 2), '-', substring(cast(sls_order_dt as varchar),7, 2)) as date) end as sls_order_dt,
    case when sls_ship_dt = 0 or length(sls_ship_dt::text) != 8 then null else
    cast(concat(substring(cast(sls_ship_dt as varchar),1, 4), '-', substring(cast(sls_ship_dt as varchar),5, 2), '-', substring(cast(sls_ship_dt as varchar),7, 2)) as date) end as sls_ship_dt,
    case when sls_due_dt = 0 or length(sls_due_dt::text) != 8 then null else
    cast(concat(substring(cast(sls_due_dt as varchar),1, 4), '-', substring(cast(sls_due_dt as varchar),5, 2), '-', substring(cast(sls_due_dt as varchar),7, 2)) as date) end as sls_due_dt,
    case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price) else sls_sales end as sls_sales , sls_quantity, 
    case when sls_price is null or sls_price <=0 then abs(sls_sales)/nullif(sls_quantity, 0) else sls_price end as sls_price
  from bronze.crm_sales_details;

-- erp_cust_az12
  insert into silver.erp_cust_az12(cid, bdate, gen)
  select 
  case when cid like 'NAS%' then substring(cid, 4, length(cid))
      else cid end as cid,
  case when bdate > now() then null else bdate end as bdate, 
  case when upper(trim(gen)) = 'F' then 'Female'
    when  upper(trim(gen))= 'M' then 'Male'
    when  upper(trim(gen)) = '' or  upper(trim(gen)) is null then 'N/A'
    else trim(gen) end as gen
  from bronze.erp_cust_az12;

-- erp_loc_a101
  insert into silver.erp_loc_a101(cid, cntry)
  select replace(cid, '-', '') as cid, case when cntry is null or trim(cntry) = '' then 'N/A' 
      when cntry like 'US%' then 'United States' 
      when cntry = 'DE' then 'Denmark'
      else trim(cntry) end cntry from bronze.erp_loc_a101;

-- erp_px_cat_g1v2
  insert into silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
  select id, cat, subcat, maintenance from bronze.erp_px_cat_g1v2;

commit;
end;$$;
call silver.load_silver();
