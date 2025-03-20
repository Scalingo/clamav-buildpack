#!/usr/bin/env bash

PATH="${PATH}:${HOME}/clamav/bin:${HOME}/clamav/sbin"
export PATH

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOME}/clamav/lib"
export LD_LIBRARY_PATH

# Whether we should start ClamAV or not (defaults is yes):
CLAMAV_START=0

# Get the process type name we're running in:
# We must support "one-off" as a valid process type name, hence using rev:
current_process_type="$( echo "${CONTAINER}" | rev | cut -d'-' -f2- | rev )"

# Create the disabled array by parsing CLAMAV_DISABLE_PROCESS_TYPES:
IFS=', ' read -r -a disabled <<< "${CLAMAV_DISABLE_PROCESS_TYPES:-""}"

# Check if we are in a process type for which we **don't** want to start ClamAV:
for p in "${disabled[@]}"; do
	if [ "${p}" == "${current_process_type}" ]; then
		CLAMAV_START=1
		break
	fi
done

export CLAMAV_START
