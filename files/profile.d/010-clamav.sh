#!/usr/bin/env bash

PATH="${PATH}:${HOME}/clamav/bin:${HOME}/clamav/sbin"
export PATH

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOME}/clamav/lib"
export LD_LIBRARY_PATH

# Whether we should start ClamAV or not (defaults is yes):
CLAMAV_START=0

# Get the process type name we're running in.
# The Bash expansion allows us to remove the shortest suffix matching -*,
# effectively removing the last hyphen and everything after it.
current_process_type="${CONTAINER%-*}"

# Create the disabled array by parsing CLAMAV_DISABLE_PROCESS_TYPES
# Defaults to "postdeploy,one-off" when CLAMAV_DISABLE_PROCESS_TYPES is unset.
IFS=', ' read -r -a disabled \
	<<< "${CLAMAV_DISABLE_PROCESS_TYPES:-"postdeploy,one-off"}"

# Check if we are in a process type for which we **don't** want to start ClamAV:
for p in "${disabled[@]}"; do
	if [[ "${p}" == "${current_process_type}" ]]; then
		CLAMAV_START=1
		break
	fi
done

export CLAMAV_START
