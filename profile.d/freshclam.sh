#!/usr/bin/env bash

# Starts freshclam daemon unless FRESHCLAM_DISABLE_DAEMON is set.

if [ -z "${FRESHCLAM_DISABLE_DAEMON}" ]
then
    freshclam --daemon --stdout --config-file="${HOME}/clamav/freshclam.conf"
fi

exit 0
