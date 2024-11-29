use data_spark;
select * from customers;
select * from exchange_rates;
select * from products;
select * from sales;
select * from stores;

-- queries for insights 

-- 1 overall male count 
SELECT COUNT(Gender) AS Male_count
FROM customers
WHERE Gender="Male";

-- 2. overall female count
SELECT COUNT(Gender) AS Female_count
FROM customers
WHERE Gender="Female";

-- 3. Overall count of customers
SELECT COUNT(DISTINCT s.CustomerKey) AS customer_count
FROM sales s;

-- 4. count of customers by country
SELECT st.Country, COUNT(DISTINCT s.CustomerKey) AS customer_count
FROM sales s
JOIN stores st ON s.StoreKey = st.StoreKey
GROUP BY st.country
ORDER BY customer_count DESC;

-- 5. count of stores by country
SELECT Country, COUNT(StoreKey) AS Store_counts
FROM stores
GROUP BY Country
ORDER BY COUNT(StoreKey);

-- 6. store-wise sales
SELECT s.StoreKey, st.Country, ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2) AS total_sales_amount
FROM products pd
JOIN sales s ON pd.ProductKey = s.ProductKey
JOIN stores st ON s.StoreKey = st.StoreKey
GROUP BY s.StoreKey, st.Country;

-- 7. country-wise sales
SELECT st.Country, ROUND(SUM(pd.Unit_Price_USD * s.Quantity),2) AS country_wise_sales
FROM products pd
JOIN sales s ON pd.ProductKey = s.ProductKey
JOIN stores st ON s.StoreKey = st.StoreKey
GROUP BY st.Country;

-- 8. overall selling amount
SELECT SUM(pd.Unit_Price_USD * s.Quantity) AS total_sales_amount
FROM products pd
JOIN sales s ON pd.ProductKey = s.ProductKey;

-- 9.  product count
SELECT Brand , COUNT(ProductKey) AS product_count
FROM products
GROUP BY Brand;

-- 10. cost price & selling price difference and profit percent
SELECT Product_Name,
	   Unit_Price_USD,Unit_Cost_USD,
       ROUND((Unit_Price_USD - Unit_Cost_USD),2) AS diff,
       ROUND((((Unit_Price_USD - Unit_Cost_USD) / Unit_Cost_USD) * 100),2) AS profit_percent
FROM products;

-- 11. brand-wise selling amount
SELECT Brand, ROUND(SUM(pd.Unit_Price_USD * s.Quantity),2) AS sales_amount
FROM products pd
JOIN sales s ON pd.ProductKey = s.ProductKey
GROUP BY Brand;

-- 12. subcategory-wise selling price
SELECT Subcategory, ROUND(SUM(pd.Unit_Price_USD * s.Quantity),2) AS sales_amount
FROM products pd
JOIN sales s ON pd.ProductKey = s.ProductKey
GROUP BY Subcategory
ORDER BY sales_amount DESC;

-- 13. year-wise brand sales
SELECT YEAR(Order_Date), 
       pd.Brand,
       ROUND(SUM(pd.Unit_Price_USD * s.Quantity),2) AS yearly_sales_amount
FROM sales s
JOIN products pd ON s.ProductKey = pd.ProductKey
GROUP BY YEAR(Order_Date), pd.Brand;

-- 14. month-wise brand sales
SELECT MONTH(Order_Date),
       pd.Brand,
       ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2) AS monthly_sales_amount
FROM sales s
JOIN products pd ON s.ProductKey = pd.ProductKey
GROUP BY MONTH(Order_Date), pd.Brand;

-- 15. year and month-wise sales
SELECT YEAR(Order_Date), MONTH(Order_Date),
       pd.Brand,
       ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2) AS sales_amount
FROM sales s
JOIN products pd ON s.ProductKey = pd.ProductKey
GROUP BY YEAR(Order_Date), MONTH(Order_date), pd.Brand;

-- 16. comparing current month and previous month sales
SELECT YEAR(Order_Date), 
	   MONTH(Order_Date),
       ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2) AS current_month_sales,
       LAG(ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2))
       OVER(ORDER BY YEAR(Order_Date), MONTH(Order_Date)) AS previous_month_sales,
       ROUND(ROUND(SUM(pd.Unit_Price_USD * s.Quantity),2) - 
       LAG(ROUND(SUM(pd.Unit_Price_USD * s.Quantity),2)) 
       OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date)), 2) AS diff_in_sales
FROM sales s
JOIN products pd ON s.ProductKey = pd.ProductKey
GROUP BY YEAR(Order_Date), MONTH(Order_Date);

-- 17. comparing current year and previous year sales
SELECT YEAR(Order_Date),
	   ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2) AS current_year_sales,
       LAG(ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2))
       OVER(ORDER BY YEAR(Order_Date)) AS previous_year_sales,
	   ROUND(ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2) -
       LAG(ROUND(SUM(pd.Unit_Price_USD * s.Quantity), 2))
       OVER(ORDER BY YEAR(Order_Date)), 2)AS diff_in_sales
FROM sales s
JOIN products pd ON s.ProductKey = pd.ProductKey
GROUP BY YEAR(Order_Date);

-- 18. year-wise profit
SELECT YEAR(Order_Date) AS year,
       ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - 
       SUM(pd.Unit_Cost_USD * s.Quantity)), 2) AS current_year_profit,
       LAG(ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - SUM(pd.Unit_Cost_USD * s.Quantity)), 2))
       OVER(ORDER BY YEAR(Order_Date)) AS previous_year_profit,
       ROUND(ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - 
       SUM(pd.Unit_Cost_USD * s.Quantity)), 2) - 
       LAG(ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - SUM(pd.Unit_Cost_USD * s.Quantity)), 2))
       OVER(ORDER BY YEAR(Order_Date)), 2) AS diff_in_profit,
       ROUND(((ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - 
       SUM(pd.Unit_Cost_USD * s.Quantity)), 2) -
       LAG(ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - SUM(pd.Unit_Cost_USD * s.Quantity)), 2))
       OVER(ORDER BY YEAR(Order_Date)) ) / 
       LAG(ROUND((SUM(pd.Unit_Price_USD * s.Quantity) - SUM(pd.Unit_Cost_USD * s.Quantity)), 2))
       OVER(ORDER BY YEAR(Order_Date)) ) * 100, 2)AS profit_percent
FROM sales s
JOIN products pd ON s.Productkey = pd.Productkey
GROUP BY (YEAR(Order_Date));
