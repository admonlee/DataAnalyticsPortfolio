/*
My solutions to questions on sql-practice.com, northwind.db set
*/

-- Q1
SELECT category_name, description
FROM categories
ORDER BY category_name;

-- Q2
SELECT category_name, description
FROM categories
ORDER BY category_name;

-- Q3
SELECT order_date, shipped_date, customer_id, freight
FROM orders
WHERE order_date = '2018-02-26';

-- Q4
SELECT employee_id, order_id, customer_id, required_date, shipped_date
FROM orders
WHERE shipped_date > required_date;

-- Q5
SELECT order_id
FROM orders
WHERE MOD(order_id, 2) = 0;

-- Q6
SELECT city, company_name, contact_name
FROM customers
WHERE city LIKE '%l%' OR '%L%'
order by contact_name;

-- Q7
SELECT company_name, contact_name, fax
FROM customers
WHERE fax IS NOT NULL;

-- Q8
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date = (SELECT MAX(hire_date) from employees);

-- Q9
SELECT ROUND(AVG(unit_price), 2) AS average_price, 
		SUM(units_in_stock) AS total_stock, SUM(discontinued) AS total_discount
FROM products;

-- Q10
SELECT p.product_name, s.company_name, c.category_name
FROM products AS p
JOIN categories AS c
	ON p.category_id = c.category_id
JOIN suppliers AS s
	ON s.supplier_id = p.supplier_id;

-- Q11
SELECT category_name, ROUND(AVG(unit_price), 2)
FROM products
JOIN categories
ON categories.category_id = products.category_id
GROUP BY category_name;

-- Q12
SELECT city, company_name, contact_name, 'customers' FROM customers
UNION ALL
SELECT city, company_name, contact_name, 'suppliers' FROM suppliers;

-- Q13
select first_name, last_name, count(*) AS num_orders, shipped
FROM(SELECT e.first_name, e.last_name, o.order_id, e.employee_id,
	CASE WHEN o.shipped_date < o.required_date THEN 'On Time'
    ELSE 'Late'
    END AS shipped 
FROM employees AS e 
JOIN orders AS o
ON e.employee_id = o.employee_id)
GROUP BY shipped, employee_id
ORDER BY last_name, first_name, shipped DESC;