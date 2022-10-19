#!/usr/bin/env bash

# Starts freshclam daemon unless FRESHCLAM_DISABLE_DAEMON is set.

if [ -z "${FRESHCLAM_DISABLE_DAEMON}" ]
then
    # Wait a random amount of time to make sure instances DO NOT start
    # freshclam at the same time.
    # This avoids hammering the database server. It also avoids to be banned.
    sleep $[ ( $RANDOM % 3600 ) + 1 ]s \
        && freshclam \
            --config-file="${HOME}/clamav/freshclam.conf" \
            --daemon \
            --stdout
fi

exit 0
