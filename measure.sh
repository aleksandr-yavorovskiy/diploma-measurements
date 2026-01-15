#!/bin/bash

PG_HOST="localhost"
PG_PORT=5432
RUNS=40

QUERY_DIR="queries"
PARQUET_QUERY_DIR="${QUERY_DIR}/parquet"
RES_DIR="results"

RES_PG="postgres"
RES_DUCKDB="pg_duckdb"
RES_DUCKDB_PARQUET="pg_duckdb_parquet"


run_queries_pg() {
    local queries_dir="$1"
    local runs=$2
    local res_name_prefix="$3"
    local duckdb_flag="$4"

    for sql_file in "$queries_dir"/*.sql; do
        query_name=$(basename "$sql_file" .sql)
        echo
        echo "========================================"
        echo "Running: ${query_name}"
        echo "========================================"

        for ((i=1;i<=$runs;i++)); do
            echo "Run #$i..."
            result=$(PGPASSWORD="${PG_PASSWORD}" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" -q -X <<EOF
SET duckdb.force_execution = ${duckdb_flag};
\timing on
$(cat "$sql_file")
EOF
)
            time_ms=$(echo "RESULT: $result" | grep "^Time:" | awk '{print $2}')
            echo "Time: ${time_ms} ms"
            echo $time_ms >> "${RES_DIR}/${res_name_prefix}_${query_name}.dat"
        done
    done
}

run_measurements() {
    rm -rf $RES_DIR
    mkdir $RES_DIR

    run_queries_pg $QUERY_DIR $RUNS $RES_PG "false"
    run_queries_pg $QUERY_DIR $RUNS $RES_DUCKDB "true"
    run_queries_pg $PARQUET_QUERY_DIR $RUNS $RES_DUCKDB_PARQUET "true"
}

run_measurements

