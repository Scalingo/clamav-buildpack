#!/usr/bin/env bash

start_freshclam() {
	local config="${HOME}/clamav/conf/freshclam.conf"
	local logfile="/tmp/freshclam.log"

	local started_at
	local tail_pid
	local status

	# Forward freshclam logs to stdout
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
		freshclam --daemon --foreground --config-file="${config}" \
			|| status="${?}"

		printf "freshclam exited with status %s. Restarting...\n" "${status}" \
			>&2

		# Only try to restart if freshclam previously ran for more than 60s
		# This avoids too frequent restart attempts
		if (( SECONDS - started_at < 60 )); then
			sleep 60
		fi
	done
}

# Only start Freshclam if conditions are met.
# `CLAMAV_START` is computed in 010-clamav.sh
if [[ -z "${FRESHCLAM_DISABLE_DAEMON:-}" && "${CLAMAV_START:-1}" == "0" ]]
then
	# Wait a random amount of time to make sure instances DO NOT start
	# freshclam at the same time.
	# This avoids hammering the database server. It also avoids to be banned.
	sleep $((( RANDOM%3600)+1))s

	start_freshclam &
fi
