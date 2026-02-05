#!/usr/bin/env bash

set -euo pipefail

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_sql_script>"
    exit 1
fi

gcloud spanner cli test-db \
    --instance test-instance \
    --source "$1" \
    --configuration=emulator-config \
    --project=emulator-project \
    --host=localhost \
    --port=9010
