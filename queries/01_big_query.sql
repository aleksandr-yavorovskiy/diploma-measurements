SELECT
order_day,
orders_count,
daily_revenue,
AVG(daily_revenue) OVER (
	ORDER BY order_day
	ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS revenue_7d_avg
FROM (
    SELECT
        DATE(order_timestamp) AS order_day,
        COUNT(*) AS orders_count,
        SUM(total_amount) AS daily_revenue
    FROM customer_orders
    WHERE is_paid = true
    GROUP BY DATE(order_timestamp)
) t
ORDER BY order_day;
