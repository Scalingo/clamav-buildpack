#!/usr/bin/env bash

# Starts clamd daemon unless CLAMD_DISABLE_DAEMON is set.

start_clamd() {
    clamd --config-file="${HOME}/clamav/clamd.conf"
}

if [ -z "${CLAMD_DISABLE_DAEMON}" ]
then
    start_clamd

    while true
    do
        pidof "clamd" >/dev/null \
            && sleep 15 \
            || {
                echo "ClamAV daemon does not seem to be running. Respawning." >&2
                start_clamd
            }
    done &
fi

exit 0
