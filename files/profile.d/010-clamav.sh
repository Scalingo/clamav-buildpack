#!/usr/bin/env bash

PATH="${PATH}:${HOME}/clamav/bin:${HOME}/clamav/sbin"
export PATH

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOME}/clamav/lib"
export LD_LIBRARY_PATH

# Whether we should start ClamAV or not:
CLAMAV_START=1

# Get the process type name we're running in:
# We must support "one-off" as a valid process type name, hence using rev:
current_process_type="$( echo "${CONTAINER}" | rev | cut -d'-' -f2- | rev )"

# Create the process_types array from CLAMAV_PROCESS_TYPES:
IFS=', ' read -r -a process_types <<< "${CLAMAV_PROCESS_TYPES:-"web"}"

# Check if we are in a process type for which we want to start ClamAV:
for p in "${process_types[@]}"; do
	if [ "${p}" == "${current_process_type}" ]; then
		CLAMAV_START=0
		break
	fi
done

export CLAMAV_START
