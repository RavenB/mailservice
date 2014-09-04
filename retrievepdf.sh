#!/bin/bash

WORKINGDIR="`dirname \"$0\"`"              # relative
WORKINGDIR="`( cd \"$WORKINGDIR\" && pwd )`"  # absolutized and normalized
if [ -z "$WORKINGDIR" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

. $WORKINGDIR/config.sh

#WORKINGDIR="/opt/mailservice"
MUTTCMD="/usr/bin/mutt"
CURLCMD="/usr/bin/curl"

OUTPUTFOLDER="$WORKINGDIR/tmp"
LOGFOLDER="$WORKINGDIR/logs"

#SERVICEPARAMETER
SERVICEURL=http://online.htmltopdf.de/

ORIENTATION=Portrait
#ORIENTATION=Landscape

#CSS PRINT
PRINT=1
#PRINT=0

#BACKGROUND-COLORS and IMAGES
BACKGROUND=1
#BACKGROUND=0

#BASE64
#PLAIN=0
PLAIN=1

MAXCALLS=30

#--write-out %{http_code} 
$CURLCMD -vs --retry 50 --retry-delay 900 -L -# -o "$OUTPUTFOLDER/$FILENAME" -X POST -F "url=$URL" -F "orientation=$ORIENTATION" -F "print=$PRINT" -F "background=$BACKGROUND" -F "plain=$PLAIN" "$SERVICEURL" 2> "$LOGFOLDER/log_$FILENAMETIME.log"

STATUS=$?
if [ $STATUS -ne 0 ]
then
	echo "ERROR $STATUS"
	sleep 10m
	#RETRY AFTER 10MIN TIMEOUT WITH ARGUMENT WHICH COUNTS ATTEMPTS
	#AFTER A SPECIFIED NUMBER OF RETRIES (60) ABBORT AND SEND ERROR MAIL WITH
	#LAST LOG FILE AS ATTACHEMENT
	if [ $# -ne 1 ]
	then
		echo "RETRY ... 1"
		./$0 1
	else
		COUNT=$[$1+1]
		if [ $COUNT -ge $MAXCALLS ]
		then
			ERRORSUBJECT="ERROR: Daten für Rhein - Rheinfelden (2091) von $FILENAMETIME"
			ERROREMAILMESSAGE="$WORKINGDIR/errormessage.txt"

			$MUTTCMD -s "$ERRORSUBJECT" -a "$LOGFOLDER/log_$FILENAMETIME.log" -b "$BCC" "$EMAIL" < "$ERROREMAILMESSAGE"	
			exit $STATUS
		else
			echo "RETRY ... $COUNT"
			./$0 $COUNT
			exit $STATUS
		fi
	fi
else
	################################
	# MAIL
	################################

	SUBJECT="Daten für Rhein - Rheinfelden (2091) von $FILENAMETIME"
	EMAILMESSAGE="$WORKINGDIR/mailmessage.txt"

	echo "Sending mail ..."

	$MUTTCMD -s "$SUBJECT" -b "$BCC" "$EMAIL" -a "$OUTPUTFOLDER/$FILENAME" < "$EMAILMESSAGE"
	exit 0
fi
