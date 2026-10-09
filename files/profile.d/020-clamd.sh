#!/usr/bin/env bash

# Starts clamd daemon only if:
# - we are running in the appropriate process type,
# - AND if CLAMD_DISABLE_DAEMON is unset.

start_clamd() {
	clamd --config-file="${HOME}/clamav/conf/clamd.conf"
}

ensure_clamd() {
	start_clamd

	while true
	do
		sleep 15s
		pidof "clamd" > /dev/null \
			|| {
				echo "ClamAV daemon does not seem to be running. Respawning." >&2
				start_clamd
			}
	done &
}

# Only start ClamAV if the conditions are OK
# `CLAMAV_START` is computed in 010-clamav.sh
if [[ -z "${CLAMD_DISABLE_DAEMON}" ]] && [[ "${CLAMAV_START}" -eq 0 ]]; then

	# Use tail to send logs to stdout.
	# clamd rotates the file.
	logfile="/tmp/clamd.log"
	touch "${logfile}"
	tail --lines=0 -F "${logfile}" &

	ensure_clamd
fi
