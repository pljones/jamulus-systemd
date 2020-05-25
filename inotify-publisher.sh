#!/bin/bash -e

MOST_RECENT=0

# Get the variables
JAMULUS=Jamulus
JAMULUS_ROOT=/opt/$JAMULUS
JAMULUS_BINDIR=$JAMULUS_ROOT/bin
. /opt/Jamulus/systemd/server.env

# Canonicalise the variables we need
JAMULUS_RECORDING_DIR=$(realpath "${JAMULUS_RECORDING_DIR}")
JAMULUS_STATUSPAGE=$(realpath "${JAMULUS_STATUSPAGE}")
PUBLISH_SCRIPT=$(realpath "${JAMULUS_BINDIR}/publish-recordings.sh")

# Do not return until a new jamdir exists in the recording dir
wait_for_new_jamdir () {
	while [[ ${MOST_RECENT} -ge $(date -r "${JAMULUS_RECORDING_DIR}" "+%s")
		|| -z $(find "${JAMULUS_RECORDING_DIR}" -mindepth 1 -type d -prune) ]]
	do
		inotifywait -q -e create -e close_write "${JAMULUS_RECORDING_DIR}"
	done
	true
}

# Do not return until the server has no connections
wait_for_quiet () {
	# wait until the status page exists
	while ! test -f "${JAMULUS_STATUSPAGE}"
	do
		inotifywait -q -e create -e close_write "${JAMULUS_STATUSPAGE}"
	done

	# wait until no one connected
	while ! grep -q 'No client connected' "${JAMULUS_STATUSPAGE}"
	do
		inotifywait -q -e close_write "${JAMULUS_STATUSPAGE}"
	done
	true
}

while wait_for_new_jamdir && wait_for_quiet
do
	MOST_RECENT=$(date -r "${JAMULUS_RECORDING_DIR}" "+%s")
	"${PUBLISH_SCRIPT}"
done
