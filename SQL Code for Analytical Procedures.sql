/* 1. What categories and subcategories do our products belong to? */

/* Our Products */
SELECT "public"."product_categories"."category" AS "category", count(*) AS "count"
FROM "public"."product_categories"
GROUP BY "public"."product_categories"."category"
ORDER BY "count" DESC, "public"."product_categories"."category" ASC
/* Sub category distribution */
SELECT "public"."product_categories"."sub_category" AS "sub_category", "public"."product_categories"."category" AS "category", count(*) AS "count"
FROM "public"."product_categories"
GROUP BY "public"."product_categories"."sub_category", "public"."product_categories"."category"
ORDER BY "public"."product_categories"."sub_category" ASC, "public"."product_categories"."category" ASC

/* 2. What’s the relationship between unit price and profit (will higher prices lead to higher profits)? */
SELECT date_trunc('month', CAST("public"."transactions"."order_date" AS timestamp)) AS "order_date", ((floor((("products__via__product_id"."unit_price" - 0.0) / 1000)) * 1000) + 0.0) AS "unit_price", avg("public"."transactions"."profit") AS "avg"
FROM "public"."transactions"
LEFT JOIN "public"."products" "products__via__product_id" ON "public"."transactions"."product_id" = "products__via__product_id"."product_id"
GROUP BY date_trunc('month', CAST("public"."transactions"."order_date" AS timestamp)), ((floor((("products__via__product_id"."unit_price" - 0.0) / 1000)) * 1000) + 0.0)
ORDER BY date_trunc('month', CAST("public"."transactions"."order_date" AS timestamp)) ASC, ((floor((("products__via__product_id"."unit_price" - 0.0) / 1000)) * 1000) + 0.0) ASC

/* 3. Which products do our customers usually buy together? */
SELECT "public"."transactions"."product_id" AS "product_id", "customers__via__customer_id"."customer_name" AS "customer_name", avg("public"."transactions"."quantity_ordered") AS "avg"
FROM "public"."transactions"
LEFT JOIN "public"."customers" "customers__via__customer_id" ON "public"."transactions"."customer_id" = "customers__via__customer_id"."customer_id"
GROUP BY "public"."transactions"."product_id", "customers__via__customer_id"."customer_name"
ORDER BY "public"."transactions"."product_id" ASC, "customers__via__customer_id"."customer_name" ASC

/* 4. Which customers and locations contribute to the majority of profit in each state? */
SELECT ((floor((("public"."transactions"."profit" - -16500.0) / 500)) * 500) + -16500.0) AS "profit", "public"."transactions"."customer_id" AS "customer_id", "customers__via__customer_id"."zipcode" AS "zipcode"
FROM "public"."transactions"
LEFT JOIN "public"."customers" "customers__via__customer_id" ON "public"."transactions"."customer_id" = "customers__via__customer_id"."customer_id"
GROUP BY ((floor((("public"."transactions"."profit" - -16500.0) / 500)) * 500) + -16500.0), "public"."transactions"."customer_id", "customers__via__customer_id"."zipcode"
ORDER BY ((floor((("public"."transactions"."profit" - -16500.0) / 500)) * 500) + -16500.0) DESC, "public"."transactions"."customer_id" ASC, "customers__via__customer_id"."zipcode" ASC
LIMIT 2000

/* 5. Which states have the highest number of customers? */
SELECT "public"."addresses"."state" AS "state", count(*) AS "count"
FROM "public"."addresses"
GROUP BY "public"."addresses"."state"
ORDER BY "public"."addresses"."state" ASC

/* 6. Do sales promotions lead to higher profits? */
SELECT date_trunc('month', CAST("public"."transactions"."order_date" AS timestamp)) AS "order_date", ((floor((("public"."transactions"."profit" - -20000.0) / 5000)) * 5000) + -20000.0) AS "profit", sum("public"."transactions"."discount") AS "sum", avg("public"."transactions"."profit") AS "avg"
FROM "public"."transactions"
GROUP BY date_trunc('month', CAST("public"."transactions"."order_date" AS timestamp)), ((floor((("public"."transactions"."profit" - -20000.0) / 5000)) * 5000) + -20000.0)
ORDER BY date_trunc('month', CAST("public"."transactions"."order_date" AS timestamp)) ASC, ((floor((("public"."transactions"."profit" - -20000.0) / 5000)) * 5000) + -20000.0) ASC

/* 7. Which segments buys the most products? */
SELECT "segments__via__segment_id"."customer_segment" AS "customer_segment", count(*) AS "count"
FROM "public"."customer_segment"
LEFT JOIN "public"."segments" "segments__via__segment_id" ON "public"."customer_segment"."segment_id" = "segments__via__segment_id"."segment_id"
GROUP BY "segments__via__segment_id"."customer_segment"
ORDER BY "segments__via__segment_id"."customer_segment" ASC

/* 8. Are orders higher in certain times of the year? */
SELECT (date_trunc('week', CAST((CAST("public"."transactions"."order_date" AS timestamp) + INTERVAL '1 day') AS timestamp)) - INTERVAL '1 day') AS "order_date", avg("public"."transactions"."quantity_ordered") AS "avg"
FROM "public"."transactions"
GROUP BY (date_trunc('week', CAST((CAST("public"."transactions"."order_date" AS timestamp) + INTERVAL '1 day') AS timestamp)) - INTERVAL '1 day')
ORDER BY (date_trunc('week', CAST((CAST("public"."transactions"."order_date" AS timestamp) + INTERVAL '1 day') AS timestamp)) - INTERVAL '1 day') ASC

/* 9. What are our sales averages over time? */
SELECT (date_trunc('week', CAST((CAST("public"."transactions"."order_date" AS timestamp) + INTERVAL '1 day') AS timestamp)) - INTERVAL '1 day') AS "order_date", sum("public"."transactions"."sales") AS "sum", avg("public"."transactions"."sales") AS "avg"
FROM "public"."transactions"
GROUP BY (date_trunc('week', CAST((CAST("public"."transactions"."order_date" AS timestamp) + INTERVAL '1 day') AS timestamp)) - INTERVAL '1 day')
ORDER BY (date_trunc('week', CAST((CAST("public"."transactions"."order_date" AS timestamp) + INTERVAL '1 day') AS timestamp)) - INTERVAL '1 day') ASC

/* 10. Can we reduce shipping cost by eliminating certain priority? */
SELECT "public"."shippings"."ship_mode" AS "ship_mode", sum("transactions__via__transaction"."sales") AS "sum", avg("transactions__via__transaction"."sales") AS "avg"
FROM "public"."shippings"
LEFT JOIN "public"."transactions" "transactions__via__transaction" ON "public"."shippings"."transaction_id" = "transactions__via__transaction"."transaction_id"
GROUP BY "public"."shippings"."ship_mode"
ORDER BY "public"."shippings"."ship_mode" ASC

/* 11. How was the trend of company's monthly profit? */
SELECT SUM(profit) as total_profit, 
	extract(month from order_date) as month,
	extract(year from order_date) as year
FROM (transactions t JOIN customers c on t.customer_id=c.customer_id)
natural join addresses
GROUP BY year, month
ORDER BY year, month