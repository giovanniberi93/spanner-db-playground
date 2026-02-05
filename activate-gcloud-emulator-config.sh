#!/usr/bin/env bash

set -euo pipefail

GCLOUD_CONFIG_DIR="$HOME/.config/gcloud/configurations"
SOURCE_CONFIG_FILE="gcloud-config/config_emulator"
DEST_CONFIG_FILE="$GCLOUD_CONFIG_DIR/config_emulator"

# Create the destination directory if it doesn't exist
mkdir -p "$GCLOUD_CONFIG_DIR"

should_copy=false
if [ ! -f "$DEST_CONFIG_FILE" ]; then
    should_copy=true
else
    if ! cmp -s "$SOURCE_CONFIG_FILE" "$DEST_CONFIG_FILE"; then
        TIMESTAMP=$(date +%s)
        BACKUP_FILE="${DEST_CONFIG_FILE}_old_$TIMESTAMP"
        echo "Existing config file is different. Renaming to $BACKUP_FILE"
        mv "$DEST_CONFIG_FILE" "$BACKUP_FILE"
        should_copy=true
    else
        echo "Config file already esisting."
    fi
fi

if [ "$should_copy" = true ]; then
    echo "Copying config file to $DEST_CONFIG_FILE"
    cp "$SOURCE_CONFIG_FILE" "$DEST_CONFIG_FILE"
fi

echo "gcloud config for emulator has been set up."

gcloud config configurations activate emulator
