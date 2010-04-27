#!/bin/sh -uex
cd $(dirname $0)
wget 'http://www.fmwconcepts.com/imagemagick/script_list.txt' -O script_list.txt
awk -F\-\- '{ print $1}' script_list.txt | egrep '^\w' | while read name; do
    wget "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=${name}&dirname=${name}" -O ${name}
    chmod +x ${name}
done
cd -

