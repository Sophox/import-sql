#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
shopt -s nullglob

function exec_psql_file() {
    local file_name="$1"
    # Allws additional parameters to be passed to psql
    # For example, PSQL_OPTIONS='-a -A' would echo everything and disable output alignment
    # Using eval allows complex cases with quotes, like PSQL_OPTIONS=" -a -c 'select ...' "
    eval "local psql_opts=(${PSQL_OPTIONS:-})"
    PGPASSWORD="$POSTGRES_PASSWORD" psql \
        -v ON_ERROR_STOP="1" \
        --host="$POSTGRES_HOST" \
        --port="$POSTGRES_PORT" \
        --dbname="$POSTGRES_DB" \
        --username="$POSTGRES_USER" \
        -f "$file_name" \
        "${psql_opts[@]}"
}

function import_sql_files() {
    local sql_file
    for sql_file in "$SQL_DIR"/*.sql; do
        exec_psql_file "$sql_file"
        break
    done
}

function main() {
    echo '\timing' > /root/.psqlrc
    exec_psql_file "language.sql"
    exec_psql_file "$VT_UTIL_DIR/postgis-vt-util.sql"
    import_sql_files
}

main
