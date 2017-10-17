#!/bin/bash
#Author Gaëtan

usage(){
	echo "Usage: ./dl-manga.sh <fichier>";
	exit 1;
}

if [ ! $# -lt 2 ]; then
	usage
fi
file="$1"
cat $file | while  read ligne ; do
	echo "$ligne"
  ./getScan.sh "$ligne"
done
