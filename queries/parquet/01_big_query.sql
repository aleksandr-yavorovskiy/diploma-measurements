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
        DATE(r['order_timestamp']) AS order_day,
        COUNT(*) AS orders_count,
        SUM(r['total_amount']) AS daily_revenue
    FROM read_parquet('./customer_orders_100mil.parquet') AS r
    WHERE r['is_paid'] = true
    GROUP BY DATE(r['order_timestamp'])
) t
ORDER BY order_day;
