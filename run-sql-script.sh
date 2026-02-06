#!/usr/bin/env bash

set -euo pipefail

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_sql_script> [search_term]"
    exit 1
fi

SQL_SCRIPT_PATH=$1

# Check if the script contains the placeholder and if the second argument is missing
if grep -q "__SEARCH_TERM__" "$SQL_SCRIPT_PATH" && [ -z "${2:-}" ]; then
    echo "Error: The script '$SQL_SCRIPT_PATH' requires a search term as the second argument."
    exit 1
fi

SEARCH_TERM=${2:-}

TEMP_SQL_SCRIPT=$(mktemp)
trap 'rm -f "$TEMP_SQL_SCRIPT"' EXIT

# If a search term is provided, replace the placeholder. Otherwise, use the script as is.
if [ -n "$SEARCH_TERM" ]; then
    sed "s/__SEARCH_TERM__/'$SEARCH_TERM'/g" "$SQL_SCRIPT_PATH" > "$TEMP_SQL_SCRIPT"
else
    cp "$SQL_SCRIPT_PATH" "$TEMP_SQL_SCRIPT"
fi

gcloud spanner cli test-db \
    --instance test-instance \
    --source "$TEMP_SQL_SCRIPT" \
    --configuration=emulator-config \
    --project=emulator-project \
    --host=localhost \
    --port=9010
