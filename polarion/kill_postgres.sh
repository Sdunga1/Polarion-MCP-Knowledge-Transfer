#!/bin/bash

# === CONFIG ===
DATA_DIR="/opt/polarion/data/postgres-data"
PORT=5433

# === FUNCTIONS ===
function log {
    echo "[+] $1"
}

function is_postgres_running_by_pidfile {
    PIDFILE="$DATA_DIR/postmaster.pid"
    if [[ -f "$PIDFILE" ]]; then
        PID=$(head -n1 "$PIDFILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "$PID"
            return 0
        fi
    fi
    return 1
}

function is_postgres_running_by_port {
    PIDS=$(lsof -t -i :$PORT -sTCP:LISTEN -n -P 2>/dev/null)
    if [[ ! -z "$PIDS" ]]; then
        echo "$PIDS"
        return 0
    fi
    return 1
}

function kill_postgres {
    local PIDS="$1"
    for PID in $PIDS; do
        log "Sending SIGTERM to PID $PID"
        kill -15 "$PID"
    done
}

function wait_for_shutdown {
    local TIMEOUT=10
    while [[ $TIMEOUT -gt 0 ]]; do
        if ! ps -p $1 > /dev/null 2>&1; then
            log "Process $1 has stopped"
            return 0
        fi
        sleep 1
        TIMEOUT=$((TIMEOUT - 1))
    done
    log "Process $1 did not stop, sending SIGKILL"
    kill -9 "$1"
}

# === MAIN LOGIC ===

log "Checking if PostgreSQL is running via postmaster.pid..."
PID=$(is_postgres_running_by_pidfile)
if [[ $? -eq 0 ]]; then
    log "Found running PostgreSQL (PID $PID) using data dir $DATA_DIR"
    kill_postgres "$PID"
    wait_for_shutdown "$PID"
    rm -f "$DATA_DIR/postmaster.pid"
    log "Removed stale postmaster.pid"
else
    log "No active PostgreSQL process found by PID file"
fi

log "Checking for processes listening on port $PORT..."
PIDS=$(is_postgres_running_by_port)
if [[ $? -eq 0 ]]; then
    for PID in $PIDS; do
        log "Found PostgreSQL (PID $PID) listening on port $PORT"
        kill_postgres "$PID"
        wait_for_shutdown "$PID"
    done
else
    log "No PostgreSQL process found listening on port $PORT"
fi

log "PostgreSQL shutdown complete"

sudo systemctl stop postgresql@17-main