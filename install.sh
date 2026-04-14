#!/usr/bin/env bash
#--------------------------------------------------------------------------
#
# pgEdge AI DBA Workbench
#
# Copyright (c) 2025 - 2026, pgEdge, Inc.
# This software is released under The PostgreSQL License
#
#--------------------------------------------------------------------------
set -euo pipefail

# Entrypoint for curl-pipe installation:
#   curl -fsSL https://raw.githubusercontent.com/AntTheLimey/ai-dba-walkthrough/main/install.sh | bash

WORK_DIR="${WALKTHROUGH_DIR:-pgedge-workbench-walkthrough}"
BRANCH="${PGEDGE_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/AntTheLimey/ai-dba-walkthrough/${BRANCH}"

# --- Header ---

echo ""
echo "  pgEdge AI DBA Workbench Walkthrough"
echo "  ===================================="
echo ""

# --- Download walkthrough files ---

echo "  Downloading walkthrough files..."

LOCAL_DIR="$WORK_DIR/examples/walkthrough"

mkdir -p "$LOCAL_DIR/config"
mkdir -p "$LOCAL_DIR/nginx/walkthrough/images"
mkdir -p "$LOCAL_DIR/seed"
mkdir -p "$LOCAL_DIR/secret"

# Remote paths (repo root) -> local paths (examples/walkthrough/)
REMOTE_FILES=(
  docker-compose.yml
  guide.sh
  runner.sh
  setup.sh
  config/ai-dba-server.yaml
  config/ai-dba-collector.yaml
  config/ai-dba-alerter.yaml
  nginx/nginx.conf
  nginx/walkthrough/driver.min.css
  nginx/walkthrough/driver.min.js
  nginx/walkthrough/loader.js
  nginx/walkthrough/tour.css
  nginx/walkthrough/tour.js
  seed/demo-schema.sql
  seed/rebase-timestamps.sh
  seed/datastore-seed-4h.sql
  seed/workload.sh
)

FAILED=0
for file in "${REMOTE_FILES[@]}"; do
  if ! curl -fsSL "$BASE_URL/$file" -o "$LOCAL_DIR/$file"; then
    echo "  Warning: failed to download $file" >&2
    FAILED=$((FAILED + 1))
  fi
done

if [[ $FAILED -gt 0 ]]; then
  echo ""
  echo "  Error: $FAILED file(s) failed to download." >&2
  echo "  Check your network connection and try again." >&2
  echo ""
  exit 1
fi

chmod +x "$LOCAL_DIR/guide.sh" \
         "$LOCAL_DIR/setup.sh" \
         "$LOCAL_DIR/seed/workload.sh" \
         "$LOCAL_DIR/seed/rebase-timestamps.sh"

echo "  Downloaded ${#REMOTE_FILES[@]} files."
echo ""

cd "$WORK_DIR"

# --- Run the interactive guide ---

echo "  Starting the interactive walkthrough..."
echo ""
exec bash examples/walkthrough/guide.sh
