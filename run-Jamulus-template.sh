#!/bin/bash -e
export LANG=C PATH="/usr/bin:/bin:$JAMULUS_BINDIR"
DAEMON="$JAMULUS_BINDIR/${JAMULUS}-${UNIT}"
if [ ! -x "$DAEMON" ] ; then
	echo "$DAEMON not installed." >&2
	exit 1
fi

JAMULUS_OPTS=("-s" "-n")
if [ ! -z "$JAMULUS_FASTUPDATE" ] && $JAMULUS_FASTUPDATE; then JAMULUS_OPTS+=("-F"); fi
if [ ! -z "$JAMULUS_PINGSERVERS" ] && $JAMULUS_PINGSERVERS; then JAMULUS_OPTS+=("-g"); fi

if [ ! -z "$JAMULUS_PORT" ] ; then JAMULUS_OPTS+=("-p" $JAMULUS_PORT); fi
if [ ! -z "$JAMULUS_MAXCHANS" ] ; then JAMULUS_OPTS+=("-u" $JAMULUS_MAXCHANS); fi
if [ ! -z "$JAMULUS_CENTRAL" ] ; then JAMULUS_OPTS+=("-e" "$JAMULUS_CENTRAL"); fi

if [ ! -z "$JAMULUS_STATUSPAGE" -a -z "$JAMULUS_SERVERNAME" ] ; then
	echo "if STATUSPAGE set, SERVERNAME must be set" >&2
	exit 1
fi
if [ ! -z "$JAMULUS_STATUSPAGE" ] ; then JAMULUS_OPTS+=("-m" "$JAMULUS_STATUSPAGE"); fi
if [ ! -z "$JAMULUS_LOGFILE" ] ; then JAMULUS_OPTS+=("-l" "$JAMULUS_LOGFILE"); fi
if [ ! -z "$JAMULUS_SVGHISTORY" ] ; then JAMULUS_OPTS+=("-y" "$JAMULUS_SVGHISTORY"); fi

if [ ! -z "$JAMULUS_ENABLE_RECORDING" ] && $JAMULUS_ENABLE_RECORDING && [ ! -z "$JAMULUS_RECORDING_DIR" ]
then
	JAMULUS_OPTS+=("-L" "-R" "$JAMULUS_RECORDING_DIR")
fi

if [ ! -z "$JAMULUS_SERVERNAME" ] ; then JAMULUS_OPTS+=("-a" "$JAMULUS_SERVERNAME"); fi
if [ ! -z "$JAMULUS_SERVERINFO" ] ; then JAMULUS_OPTS+=("-o" "$JAMULUS_SERVERINFO"); fi
if [ ! -z "$JAMULUS_WELCOMEMSG" ] ; then JAMULUS_OPTS+=("-w" "$JAMULUS_WELCOMEMSG"); fi

echo "Starting Jamulus server" "$JAMULUS_SERVERNAME"
if [ ! -z "$JAMULUS_STATUSPAGE" -a -e "$JAMULUS_STATUSPAGE" ] ; then
	cat > "$JAMULUS_STATUSPAGE" << !EOF
$JAMULUS_SERVERNAME Jamulus server is starting.
!EOF
fi
exec ${DAEMON} "${JAMULUS_OPTS[@]}"
