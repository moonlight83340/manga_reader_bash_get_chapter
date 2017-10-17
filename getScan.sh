#!/bin/bash
#Author Gaëtan

#main

usage(){
	echo "Usage: ./getScan.sh <name-of-manga> [target-dir]";
	exit 1;
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "usage" ];then
	usage
	exit 0
fi

if [ ! $# -lt 2 ]; then
	usage
fi
#first use jpscanlib
. jpscanlib.sh
URL="http://www.japscan.com/lecture-en-ligne/${1}/"
getChapterCount "$URL" "$1"
chapter=$?
echo $chapter
if [ $chapter -eq 0 ];then
	#if jpscan have no result we try on manga-reader
	. manga-readerlib.sh
	URL="http://www.mangareader.net/${1}"
	getChapterCount $URL $1
	chapter=$?
	echo $chapter
fi
for (( chap=1; chap<=$chapter; chap++ )); do
	get "$1" $chap "$2"
done;
exit 0

