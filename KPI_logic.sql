KPI_1 : baseline_per_category Logic : 
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

--------------------------------------------
KPI2 : Transaction_Volume logic :
---transaction_volume : catgeory_trnx_count in 2025
select p.product_name,Concat('Q',to_char(trnx_date,'Q')) as Quarters,
count(trnx_id)filter(where f.merchant_code_description LIKE '%Groceries%') as total_captured_grocery_trnxs,
count(trnx_id)filter(where f.merchant_code_description LIKE '%Streaming%') as total_captured_streaming_trnxs,
count(trnx_id)filter(where f.merchant_code_description LIKE '%Restaurant%') as total_captured_Restaurant_trnxs
from RFM_ANALYSIS.fact_transactions f 
inner join RFM_ANALYSIS.dim_products p 
on f.product_code=p.product_code 
where f.trnx_date>='01-01-2025' 
and f.trnx_date<='12-31-2025'
and f.product_code in ('101','102') 
and f.merchant_code in ('9135', '9144', '9147', '9149') 
group by p.product_name ,to_char(trnx_date,'Q') 

-----------------------------------
KPI3 : 



