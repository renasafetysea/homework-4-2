CREATE TABLE IF NOT EXISTS public.product(
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR(100),
	price MONEY
)
DISTRIBUTED BY (product_id)

CREATE TABLE IF NOT EXISTS public.sales(
	sales_id SERIAL,
	product_id INT REFERENCES product(product_id),
	sales_date DATE,
	sales_cnt INT
)
DISTRIBUTED BY (sales_id)
PARTITION BY RANGE (sales_date)
(
	START (date '2023-01-01') INCLUSIVE
 	END (date '2023-07-01') EXCLUSIVE
	EVERY (INTERVAL '1 month')
);

INSERT INTO public.product (product_name, price)
VALUES ('монитор', 1000), ('мышка', 2000), ('коврик', 500), ('кресло', 9000);

INSERT INTO public.sales (product_id, sales_date, sales_cnt)
VALUES (1, '2023-01-05', 100), (1, '2023-05-01', 300),
	   (2, '2023-02-20', 50), (2, '2023-04-20', 190),
	   (3, '2023-05-12', 87), (3, '2023-06-15', 120),
	   (4, '2023-01-25', 200), (4, '2023-02-14', 89);
	 
SET optimizer = ON;
EXPLAIN
SELECT product_name, SUM(price * sales_cnt) AS sales_total
FROM sales
JOIN product using(product_id)
WHERE product_name = 'мышка' AND sales_date > '2023-01-01' AND sales_date < '2023-05-02'
GROUP BY product_name;