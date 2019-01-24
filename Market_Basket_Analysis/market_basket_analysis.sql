DROP TABLE IF EXISTS bestseller_prod_info;
CREATE TEMP TABLE bestseller_prod_info AS (

SELECT 
      DISTINCT 
      b.orderid, 
      b.productid, 
      a.productname
FROM (
	SELECT 
	      productname, SUM(quantity) AS no_of_orders 
	FROM 
	    public.orders 
	GROUP BY 
	    productname
	ORDER BY 
	    no_of_orders DESC 
	LIMIT 10
) AS a
JOIN 
public.orders AS b
ON 
  a.productname = b.productname

);


DROP TABLE IF EXISTS prod_purchased_with_bestseller_prod;
CREATE TEMP TABLE prod_purchased_with_bestseller_prod AS (

SELECT 
     a.orderid,
     a.productid AS productid_a,
     a.productname AS productname_a,
     b.orderid AS orderid_b,
     b.productid AS productid_b,
     b.productname AS productname_b
FROM 
    bestseller_prod_info AS a, orders AS b
WHERE
   a.orderid = b.orderid AND
   a.productname <> b.productname

);

DROP TABLE IF EXISTS transactions_per_prod;
CREATE TEMP TABLE transactions_per_prod AS (

SELECT 
     productname, COUNT(*) AS transactions_per_prod 
FROM 
    public.orders
GROUP BY 
    productname

);

DROP TABLE IF EXISTS no_of_occurrences_a_and_b;
CREATE TEMP TABLE no_of_occurrences_a_and_b AS (

SELECT 
      productname_a, 
      productname_b, 
      COUNT(*) AS no_transactions_of_a_and_b_together  
FROM 
    prod_purchased_with_bestseller_prod 
GROUP BY 
    productname_a, 
    productname_b

);

DROP TABLE IF EXISTS metrics;
CREATE TEMP TABLE metrics AS (

SELECT 
     DISTINCT 
     a.productname_a,
     a.productname_b,
     c.no_transactions_of_a_and_b_together AS occurrences,
     b.transactions_per_prod AS no_trasactions_includes_prod_a,
     e.transactions_per_prod AS no_transactions_includes_prod_b,
     d.total_transactions
FROM
     prod_purchased_with_bestseller_prod AS a
LEFT JOIN 
    transactions_per_prod AS b 
ON 
  a.productname_a = b.productname
LEFT JOIN 
    transactions_per_prod AS e
ON
  a.productname_b = e.productname
LEFT JOIN 
  no_of_occurrences_a_and_b AS c
ON 
  a.productname_a = c.productname_a AND
  a.productname_b = c.productname_b
CROSS JOIN 
  (SELECT COUNT(DISTINCT orderid) AS total_transactions FROM public.orders) AS d
  
);


SELECT 
      *
FROM ( 
	SELECT 
	     productname_a,
	     productname_b,
	     occurrences,
	     ROUND(CAST(no_trasactions_includes_prod_a AS DECIMAL) / total_transactions, 3) AS support_a,
	     ROUND(CAST(occurrences AS DECIMAL) / no_trasactions_includes_prod_a, 3) AS confidence,
	     ROUND((CAST(occurrences AS DECIMAL) / no_trasactions_includes_prod_a) / no_transactions_includes_prod_b, 3) AS lift_ratio
	FROM 
	    metrics
) AS a

WHERE
    a.support_a >= 0.2 AND
    a.confidence >= 0.6 AND
    a.lift_ratio > 1
;