#!/usr/bin/env bash

clamav::clamd::start() {
	local config="${HOME}/clamav/conf/clamd.conf"
	local logfile="/tmp/clamd.log"

	local started_at
	local tail_pid
	local status

	# Forward clamd logs to stdout
	tail --lines=0 -F "${logfile}" > /dev/stdout &
	tail_pid=$!

	# Stop tail on EXIT
	trap 'kill "${tail_pid}" 2>/dev/null || true' EXIT

	while true; do
		# $SECONDS is a special built-in Bash variable that contains the number
		# of seconds elapsed since the shell started.
		# It's automatically maintained by Bash.
		started_at="${SECONDS}"

		# The 'or' statement allows to be compatible with `set -o errexit`
		status=0
		clamd --foreground --config-file="${config}" \
			|| status="${?}"

		printf "clamd exited with status %s. Restarting...\n" "${status}" \
			>&2

		# Only try to restart if clamd previously ran for more than 15s
		# This avoids too frequent restart attempts
		if (( SECONDS - started_at < 15 )); then
			sleep 5
		fi
	done
}


# Only start ClamAV if the conditions are OK
# `CLAMAV_START` is computed in 010-clamav.sh
if [[ -z "${CLAMD_DISABLE_DAEMON:-}" && "${CLAMAV_START:-1}" == "0" ]]; then
	clamav::clamd::start &
fi
