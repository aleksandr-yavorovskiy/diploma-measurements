SELECT *
FROM read_parquet('./customer_orders_100mil.parquet') AS r
WHERE r['customer_id'] = 1
  AND r['is_paid'] = true;
