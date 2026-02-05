#!/usr/bin/env bash

set -euo pipefail

IMAGE="gcr.io/cloud-spanner-emulator/emulator:latest"

echo "Pulling the latest Spanner emulator image..."
docker pull "$IMAGE"

echo "Starting the Spanner emulator..."
docker run -d -p 9010:9010 -p 9020:9020 "$IMAGE"

echo "Spanner emulator started."

gcloud spanner instances create test-instance --config=emulator-config --description="Test Instance" --nodes=1

gcloud spanner databases create test-db --instance test-instance

echo "Database created."

