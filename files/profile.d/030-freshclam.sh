#!/usr/bin/env bash

# Starts freshclam daemon unless FRESHCLAM_DISABLE_DAEMON is set.

start_freshclam() {
    freshclam \
        --config-file="${HOME}/clamav/freshclam.conf" \
        --daemon \
        --stdout
}

ensure_freshclam() {
    start_freshclam

    while true
    do
        sleep 15s
        pidof "freshclam" > /dev/null \
            || {
                echo "Freshclam does not seem to be running. Respawning." >&2
                start_freshclam
            }
    done &
}

if [ -z "${FRESHCLAM_DISABLE_DAEMON}" ]
then
	(
        # Wait a random amount of time to make sure instances DO NOT start
        # freshclam at the same time.
        # This avoids hammering the database server. It also avoids to be banned.
        sleep $(((RANDOM%3600)+1))s
        ensure_freshclam
    ) &
fi
