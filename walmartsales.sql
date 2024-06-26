CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL (10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL (12,4) NOT NULL,
    ratimg FLOAT(2,1)
);

SELECT count(*) FROM walmartsales.sales; 

-- ----------------------FEATURE ENGINEERING--------------------------------------

-- ---------------------Time Of Day-----------------------------------------------
SELECT 
	time,
		(CASE 
			WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
            WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
            Else "Evening"
		END
        ) As time_of_day
    FROM sales;
    
ALTER table sales ADD time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		Else "Evening"
	END);
    
-- ----------------------Day Name----------------------------------------------------
SELECT 
	date,
    dayname(date)
FROM sales;
    
ALTER table sales ADD day_name VARCHAR(10);
UPDATE sales 
SET day_name = dayname(DATE);

-- ----------------------Month Name---------------------------------------------------

SELECT 
	date, 
    monthname(DATE) 
FROM sales;    

ALTER table sales ADD month_name VARCHAR(10);
UPDATE sales
SET month_name = monthname(DATE);
    
-- ------------------------------------------------------------------------------------

-- -----------------------------------Generic Questions---------------------------------  

-- How many unique cities does the data have?
SELECT 
	distinct city 
from sales;
-- In which city is each branch?
SELECT  
	distinct branch 
from sales;

SELECT  
	distinct city,branch
from sales;

-- -----------------------------------Product-------------------------------------------

-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT payment_method,count(payment_method) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;

-- What is the most selling product line?
SELECT product_line,COUNT(product_line) AS count
FROM sales
GROUP BY product_line
ORDER BY count DESC;

-- What is the total revenue by month?
SELECT month_name,SUM(total) AS revenue
FROM sales
GROUP BY month_name 
ORDER BY revenue DESC ;

-- What month had the largest COGS?
SELECT month_name,SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?
SELECT branch,city,SUM(total) AS revenue
FROM sales
GROUP BY city,branch
ORDER BY revenue DESC;

-- What product line had the largest VAT?
SELECT product_line,avg(vat) AS vat
FROM sales
GROUP BY product_line
ORDER BY vat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line,SUM(quantity) AS total_sales,
	(CASE
		WHEN SUM(quantity) > (SELECT AVG(quantity) FROM sales) THEN "GOOD"
        ELSE "BAD"
    END) AS sales_status
FROM sales
GROUP BY product_line;

ALTER table sales ADD sales_status VARCHAR(10);

UPDATE sales AS s
JOIN (
    SELECT 
        product_line,
        AVG(quantity) AS avg_quantity
    FROM sales
    GROUP BY product_line
) AS avg_sales
ON s.product_line = avg_sales.product_line
SET s.sales_status = 
    CASE 
        WHEN s.quantity > avg_sales.avg_quantity THEN 'Good'
        ELSE 'Bad'
    END;



-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT gender,product_line,COUNT(product_line) AS common
FROM sales
GROUP BY gender,product_line
ORDER BY common DESC;

-- What is the average rating of each product line?
SELECT product_line,ROUND(AVG(ratimg),2) AS rating
FROM sales
GROUP BY product_line
ORDER BY rating ASC;

-- ------------------------------------------------------------------------------------

-- ---------------------------SALES---------------------------------------------------


-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
GROUP BY time_of_day;


-- Which of the customer types brings the most revenue?

SELECT
	customer_type,
    SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;
    
-- Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT 
	city,
    AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
    AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ----------------------------------------------------------------------------------

-- ---------------------------CUSTOMER-----------------------------------------------

-- How many unique customer types does the data have?\
SELECT 
	DISTINCT(customer_type) AS customers
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
	DISTINCT(payment_method) 
FROM sales;

-- What is the most common customer type?
SELECT 
	customer_type,count(*) AS customers
FROM sales
GROUP BY customer_type
ORDER BY customer_type;

-- What is the gender of most of the customers?
SELECT 
	gender,COUNT(*) AS count
FROM sales 
GROUP BY gender;

-- What is the gender distribution per branch?
SELECT 
	gender,count(*) AS count
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY count;

-- Which time of the day do customers give most ratings?
SELECT 
	time_of_day,AVG(ratimg) AS rating
FROM sales
GROUP BY time_of_day
ORDER BY rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,AVG(ratimg) AS rating
FROM sales
WHERE branch = "C"
GROUP BY time_of_day
ORDER BY rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT 
	day_name,
	AVG(ratimg) AS rating
FROM sales
GROUP BY day_name
ORDER BY rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,branch,
	AVG(ratimg) AS rating
FROM sales
WHERE branch = "C"
GROUP BY day_name,branch
ORDER BY rating DESC;



   
    
    
    
    