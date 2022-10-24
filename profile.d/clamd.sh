#!/usr/bin/env bash

# Starts clamd daemon unless CLAMD_DISABLE_DAEMON is set.

start_clamd() {
    clamd --config-file="${HOME}/clamav/clamd.conf"
}

ensure_clamd() {
    start_clamd

    while true
    do
        sleep 15
        pidof "clamd" > /dev/null \
            || {
                echo "ClamAV daemon does not seem to be running. Respawning." >&2
                start_clamd
            }
    done &
}

if [ -z "${CLAMD_DISABLE_DAEMON}" ]
then
    ensure_clamd
fi
