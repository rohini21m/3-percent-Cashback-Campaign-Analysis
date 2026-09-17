KPI_1 : baseline_per_category Logic : 

create view account_spend_per_category_view as (
SELECT 
    merchant_code, 
    merchant_code_description,
    p.product_name,
    SUM(trnx_amt) AS total_yearly_spend_per_category,   
    CONCAT('$', ROUND(SUM(trnx_amt) / 1000000.0, 1), 'M') AS yearly_category_spend_in_millions,
    
    -- 1. Fixed: Forcing a decimal division (.0) so decimals don't get truncated
    ROUND(SUM(trnx_amt) / 12.0, 2) AS avg_monthly_spend_per_category,
    
    -- 2. Fixed: Total Yearly Spend divided by Unique Customers (Formatted nicely)
    ROUND(SUM(trnx_amt) / COUNT(DISTINCT account_id), 2) AS avg_yearly_spend_per_customer_per_category,
    
    -- 3. Added: If you DID want monthly spend per customer, do the math all at once
    ROUND((SUM(trnx_amt) / 12.0) / COUNT(DISTINCT account_id), 2) AS avg_monthly_spend_per_customer_per_category

FROM RFM_ANALYSIS.fact_transactions f 
INNER JOIN RFM_ANALYSIS.dim_products p 
    ON f.product_code = p.product_code  
WHERE trnx_date >= '2025-01-01' 
  AND trnx_date <= '2025-12-31'
  AND f.product_code IN ('101', '102') 
  AND f.merchant_code IN ('9135', '9144', '9147', '9149') 
GROUP BY merchant_code, merchant_code_description, product_name

) 
select * from account_spend_per_category_view


KPI2 : Transaction_Volume logic :
-- transaction volume per category 

-- unique transaction volume per category both cards & have same trnx_count
select distinct  merchant_code, merchant_code_description,p.product_name,
count(trnx_id)over(partition by merchant_code) as total_card_trnx_per_category
from RFM_ANALYSIS.fact_transactions f 
inner join RFM_ANALYSIS.dim_products p 
on f.product_code=p.product_code 
where trnx_date>='01-01-2025' 
and trnx_date<='12-31-2025'
and f.product_code in ('101','102') 
and f.merchant_code in ('9135', '9144', '9147', '9149') 
group by merchant_code, merchant_code_description,product_name,trnx_id 
order by total_card_trnx_per_category asc 



