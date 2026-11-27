#!/usr/bin/env bash

if [[ -n "${BUILDPACK_DEBUG}" ]]; then
	set -o xtrace
fi

clamav::services::cleanup() {
#
# This function is called from "main", which makes vairables defined in "main"
# available here.
# See Bash's dynamic scoping for further details.
#
# $service_pids contains the pids of services launched. 
#
	local pid

	for pid in "${service_pids[@]}"; do
		kill "${pid}" 2> /dev/null || true
	done
	for pid in "${service_pids[@]}"; do
		wait "${pid}" 2> /dev/null || true
	done
}

clamav::service::cleanup() {
#
# This function is called when `clamav::service::start` is active, which makes
# variables defined in `clamav::service::start` available here.
# See Bash's dynamic scoping for further details.
#

	if [[ -n "${cmd_pid:-}" ]]; then
		kill "${cmd_pid}" 2> /dev/null || true
		wait "${cmd_pid}" 2> /dev/null || true
	fi
}

clamav::service::start() {
	local name="${1}"
	local start_delay="${2}"
	local restart_delay="${3}"

	# We've consumed $name, $start_delay, and $restart_delay
	# The rest of the arguments are used as command ($@ later)
	shift 3

	local cmd_pid=""
	local started_at
	local status

	# Setup traps so that we can kill the services on EXIT, TERM and INT.
	trap clamav::service::cleanup EXIT
	trap 'exit 143' TERM
	trap 'exit 130' INT

	# Wait before starting the process
	# The particular syntax ensures sleep is interruptible
	sleep "${start_delay}s" &
	cmd_pid=$!
	wait "${cmd_pid}" || true
	cmd_pid=""

	while true; do
		# $SECONDS is a special built-in Bash variable that contains the number
		# of seconds elapsed since the shell started
		# It's automatically maintained by Bash
		started_at="${SECONDS}"
		status=0

		# Start the process in background
		"$@" &

		# Save the PID of the background process
		# clamav::service::cleanup uses that PID to send the daemon a
		# termination signal
		cmd_pid=$!

		# Pauses the restart loop until the process running in background exits
		# and captures a nonzero exit status
		# The || also prevents set -e from exiting prematurely
		wait "${cmd_pid}" || status=$?
		cmd_pid=""

		printf "%s exited with status %s. Restarting.\n" \
			"${name}" "${status}" >&2

		# Only try to restart if service previously ran for more than a few
		# seconds. This avoids too frequent restart attempts
		if (( SECONDS - started_at < restart_delay )); then
			# Ensure sleep is interruptible
			sleep "${restart_delay}s" &
			cmd_pid=$!
			wait "${cmd_pid}" || true
			cmd_pid=""
		fi
	done
}


# -----------------------------------------------------------------------------
# main

# Only start if the conditions are OK
# `CLAMAV_START` is computed in .profile.d/010-clamav.sh
if [[ "${CLAMAV_START:-1}" == "0" ]]; then

	# Setup traps for subshells we'll start hereafter
	trap clamav::services::cleanup EXIT
	trap 'exit 143' TERM
	trap 'exit 130' INT

	service_pids=()

	# Isolate each service's restart loop and traps in a background
	# subshell, thanks to the parenthesis + &
	
	if [[ -z "${CLAMAV_DISABLE_FRESHCLAM:-}" ]]; then
		# Start freshclam
		(
			conf="${HOME}/clamav/conf/freshclam.conf"

			# JIT-build configuration file:
			erb "${conf}.erb" > "${conf}"

			# Wait a random amount of time to make sure instances DO NOT start
			# freshclam at the same time. This avoids hammering the database
			# server, which avoids to be banned.
			clamav::service::start "freshclam" \
				"$((RANDOM % 3600 + 1))" \
				60 \
				freshclam --daemon --foreground --config-file="${conf}"
		) &

		# Record pid for cleanup
		service_pids+=( "$!" )
	fi

	if [[ -z "${CLAMAV_DISABLE_CLAMD:-}" ]]; then
		# Start clamd
		(
			conf="${HOME}/clamav/conf/clamd.conf"

			# JIT-build configuration file:
			erb "${conf}.erb" > "${conf}"

			clamav::service::start "clamd" \
				0 \
				10 \
				clamd --foreground --config-file="${conf}"
		) &

		# Record pid for cleanup
		service_pids+=( "$!" )
	fi

	wait "${service_pids[@]}"
fi
