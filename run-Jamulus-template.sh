#!/bin/bash -e
export LANG=C PATH="/usr/bin:/bin:$JAMULUS_BINDIR"
DAEMON="$JAMULUS_BINDIR/${JAMULUS}-${UNIT}"
if [ ! -x "$DAEMON" ] ; then
	echo "$DAEMON not installed." >&2
	exit 1
fi

JAMULUS_OPTS=("-n" "-s")
if [ ! -z "$JAMULUS_PORT" ] ; then JAMULUS_OPTS+=("-p" $JAMULUS_PORT); fi
if [ ! -z "$JAMULUS_DISCONNECT" ] && $JAMULUS_DISCONNECT; then JAMULUS_OPTS+=("-d"); fi
if [ ! -z "$JAMULUS_MULTITHREADED" ] && $JAMULUS_MULTITHREADED; then JAMULUS_OPTS+=("-T"); fi
if [ ! -z "$JAMULUS_FASTUPDATE" ] && $JAMULUS_FASTUPDATE; then JAMULUS_OPTS+=("-F"); fi
if [ ! -z "$JAMULUS_DELAYPAN" ] && $JAMULUS_DELAYPAN; then JAMULUS_OPTS+=("-P"); fi
if [ ! -z "$JAMULUS_IPV6" ] && $JAMULUS_IPV6; then JAMULUS_OPTS+=("-6"); fi
if [ ! -z "$JAMULUS_MAXCHANS" ] ; then JAMULUS_OPTS+=("-u" $JAMULUS_MAXCHANS); fi
if [ ! -z "$JAMULUS_QOS" ] ; then JAMULUS_OPTS+=("-Q" $JAMULUS_QOS); fi

if [ ! -z "$JAMULUS_BINDIP" ] ; then JAMULUS_OPTS+=("--serverbindip" "$JAMULUS_BINDIP"); fi
if [ ! -z "$JAMULUS_LOGFILE" ] ; then JAMULUS_OPTS+=("-l" "$JAMULUS_LOGFILE"); fi
if [ ! -z "$JAMULUS_DIRECTORY" ] ; then JAMULUS_OPTS+=("-e" "$JAMULUS_DIRECTORY"); fi

if [ ! -z "$JAMULUS_PUBLICIP" -a -z "$JAMULUS_DIRECTORY" ] ; then
	echo "if PUBLICIP set, DIRECTORY must be set" >&2
	exit 1
fi
if [ ! -z "$JAMULUS_PUBLICIP" ] ; then JAMULUS_OPTS+=("--serverpublicip" "$JAMULUS_PUBLICIP"); fi

if [ ! "$JAMULUS_DIRECTORY" == "localhost" ] && [ ! "$JAMULUS_DIRECTORY" == "127.0.0.1" ]
then
	if [ ! -z "$JAMULUS_FILTER" ] ; then { echo "if FILTER is set, DIRECTORY must be localhost" >&2; exit 1; }; fi
	if [ ! -z "$JAMULUS_DIRECTORYFILE" ] ; then { echo "if DIRECTORYFILE is set, DIRECTORY must be localhost" >&2; exit 1; }; fi
fi
if [ ! -z "$JAMULUS_FILTER" ] ; then JAMULUS_OPTS+=("-f" "$JAMULUS_FILTER"); fi
if [ ! -z "$JAMULUS_DIRECTORYFILE" ] ; then JAMULUS_OPTS+=("--directoryfile" "$JAMULUS_DIRECTORYFILE"); fi

if [ ! -z "$JAMULUS_ENABLE_RECORDING" ] && $JAMULUS_ENABLE_RECORDING && [ ! -z "$JAMULUS_RECORDING_DIR" ]
then
	JAMULUS_OPTS+=("-R" "$JAMULUS_RECORDING_DIR")
	if [ ! -z "$JAMULUS_RECORDING_OFF" ] && $JAMULUS_RECORDING_OFF ; then JAMULUS_OPTS+=("--norecord"); fi
	if [ ! -z "$JAMULUS_ACCEPT_LICENCE" ] && $JAMULUS_ACCEPT_LICENCE ; then JAMULUS_OPTS+=("-L"); fi
fi

if [ ! -z "$JAMULUS_STATUSPAGE" -a -z "$JAMULUS_SERVERNAME" ] ; then
	echo "if STATUSPAGE set, SERVERNAME must be set" >&2
	exit 1
fi
if [ ! -z "$JAMULUS_STATUSPAGE" ] ; then JAMULUS_OPTS+=("-m" "$JAMULUS_STATUSPAGE"); fi

if [ ! -z "$JAMULUS_SERVERINFO" -a -z "$JAMULUS_DIRECTORY" ] ; then
	echo "if SERVERINFO set, DIRECTORY must be set" >&2
	exit 1
fi
if [ ! -z "$JAMULUS_SERVERINFO" ] ; then JAMULUS_OPTS+=("-o" "$JAMULUS_SERVERINFO"); fi
if [ ! -z "$JAMULUS_WELCOMEMSG" ] ; then JAMULUS_OPTS+=("-w" "$JAMULUS_WELCOMEMSG"); fi

echo "Starting Jamulus server" ;#"$JAMULUS_SERVERNAME"
if [ ! -z "$JAMULUS_STATUSPAGE" -a -e "$JAMULUS_STATUSPAGE" ] ; then
	cat > "$JAMULUS_STATUSPAGE" << !EOF
$JAMULUS_SERVERNAME Jamulus server is starting.
!EOF
fi

echo exec ${DAEMON} "${JAMULUS_OPTS[@]}"
exec ${DAEMON} "${JAMULUS_OPTS[@]}"
