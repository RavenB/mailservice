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
WKHTMLTOPDFCMD="/usr/bin/wkhtmltopdf"
PDFTKCMD="/usr/bin/pdftk"
RMCMD="/bin/rm"

OUTPUTFOLDER="$WORKINGDIR/tmp"
LOGFOLDER="$WORKINGDIR/logs"

ORIENTATION=Portrait
#ORIENTATION=Landscape

MAXCALLS=30

$WKHTMLTOPDFCMD -O $ORIENTATION $URL "$OUTPUTFOLDER/$FILENAME.tmp" 2> "$LOGFOLDER/log_$FILENAMETIME.log"


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

	EMAILMESSAGE="$WORKINGDIR/mailmessage.txt"


  $PDFTKCMD "$OUTPUTFOLDER/$FILENAME.tmp" cat 1 output "$OUTPUTFOLDER/$FILENAME"
  $RMCMD -f "$OUTPUTFOLDER/$FILENAME.tmp"

	echo "Sending mail ..."

	$MUTTCMD -s "$SUBJECT" -b "$BCC" "$EMAIL" -a "$OUTPUTFOLDER/$FILENAME" < "$EMAILMESSAGE"
	exit 0
fi
