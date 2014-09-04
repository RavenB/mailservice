# Simple htmltopdf service

This service takes a url, converts it into a pdf and sends it via mail.

# Configuration

Create a file `config.sh` and put following content into it:

    URL=<URL to retrieve>
    FILENAMETIME=`date +"%y%m%d-%H%M"`
    FILENAME="<FILENAME to store>_$FILENAMETIME.pdf"

    EMAIL="<recipient>"
    BCC="<recipient>"


    ERRORSUBJECT="ERROR: <Subject for error> $FILENAMETIME"
    SUBJECT="<Subject for success> $FILENAMETIME"

    ERRORFILE=errormessage.txt
    MSGFILE=mailmessage.txt

    NROFPAGES=<Number of pages from the pdf to send>

    WKHTMLTOPDFCMD=<path to wkhtmltopdf - defaults to "/usr/bin/wkhtmltopdf">
# Prerequists

* wkhtmltopdf
* pdftk
* mutt
