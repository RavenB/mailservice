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
WGETCMD=${WGETCMD:-"/usr/local/bin/wget"}
PDFTKCMD="/usr/bin/pdftk"
RMCMD="/bin/rm"
CSV2XLSCMD="python csv2xls.py"

OUTPUTFOLDER="$WORKINGDIR/tmp"
LOGFOLDER="$WORKINGDIR/logs"

ORIENTATION=Portrait
#ORIENTATION=Landscape

MAXCALLS=30

$WGETCMD $URL1 -O "$OUTPUTFOLDER/$TMPFILENAME1" -a "$LOGFOLDER/log_$FILENAMETIME.log"
$WGETCMD $URL2 -O "$OUTPUTFOLDER/$TMPFILENAME2" -a "$LOGFOLDER/log_$FILENAMETIME.log"
$WGETCMD $URL3 -O "$OUTPUTFOLDER/$TMPFILENAME3" -a "$LOGFOLDER/log_$FILENAMETIME.log"

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
			ERROREMAILMESSAGE="$WORKINGDIR/$ERRORFILE"

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

	EMAILMESSAGE="$WORKINGDIR/$MSGFILE"


	# $PDFTKCMD "$OUTPUTFOLDER/$FILENAME.tmp" cat $NROFPAGES output "$OUTPUTFOLDER/$FILENAME"
  $CSV2XLSCMD "$OUTPUTFOLDER/$TMPFILENAME1" "$OUTPUTFOLDER/$TMPFILENAME2" "$OUTPUTFOLDER/$TMPFILENAME3" "$OUTPUTFOLDER/$FILENAME"

	$RMCMD -f "$OUTPUTFOLDER/$TMPFILENAME1"
	$RMCMD -f "$OUTPUTFOLDER/$TMPFILENAME2"
	$RMCMD -f "$OUTPUTFOLDER/$TMPFILENAME3"

	echo "Sending mail ..."

  $MUTTCMD -s "$SUBJECT" -b "$BCC" "$EMAIL" -a "$OUTPUTFOLDER/$FILENAME" < "$EMAILMESSAGE"
	exit 0
fi
