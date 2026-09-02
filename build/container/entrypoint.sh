#!/bin/sh
# SPDX-License-Identifier: MPL-2.0
# X15-rocket-glider container entrypoint
#
# Handles signal propagation, startup logging, and health check
# preparation before exec-ing into the main application process.

set -e

# ---------------------------------------------------------------------------
# Signal handling
# ---------------------------------------------------------------------------
#
# Trap SIGTERM and SIGINT so that the application can shut down gracefully
# when Podman sends stop signals (e.g. `podman stop`, `selur-compose down`).

cleanup() {
    echo "Received shutdown signal — stopping x15-rocket-glider..."
    # If the main process is backgrounded, kill it here:
    # kill "$MAIN_PID" 2>/dev/null || true
    # wait "$MAIN_PID" 2>/dev/null || true
    exit 0
}
trap cleanup TERM INT

# ---------------------------------------------------------------------------
# Startup logging
# ---------------------------------------------------------------------------

echo "Starting x15-rocket-glider..."
echo "  Host: ${APP_HOST:-[::]}"
echo "  Port: ${APP_PORT:-8080}"
echo "  Data: ${APP_DATA_DIR:-/data}"
echo "  Log:  ${APP_LOG_FORMAT:-json}"

# ---------------------------------------------------------------------------
# Health check preparation
# ---------------------------------------------------------------------------
#
# Ensure the data directory exists and is writable.
# The VOLUME directive in the Containerfile creates /data, but a bind-mount
# might replace it with an empty directory owned by root.

if [ -d "${APP_DATA_DIR:-/data}" ]; then
    if [ ! -w "${APP_DATA_DIR:-/data}" ]; then
        echo "WARNING: ${APP_DATA_DIR:-/data} is not writable by $(whoami)"
    fi
fi

# ---------------------------------------------------------------------------
# Exec into main process
# ---------------------------------------------------------------------------
#
# Replace the entrypoint shell with the application process so that
# signals are delivered directly and PID 1 is the application.
#
# TODO: Replace the command below with your application binary.
# Examples:
#   exec /app/x15-rocket-glider
#   exec /app/release/bin/x15-rocket-glider start
#   exec /app/x15-rocket-glider serve --host "${APP_HOST}" --port "${APP_PORT}"

exec "$@"
