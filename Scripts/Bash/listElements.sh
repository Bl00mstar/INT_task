#!/bin/bash
#display elements
#Example usage
#sh listElements.sh -> list elements in current file path
#sh listElements.sh "/var/www" -> list elements in /var/www

if [ $# -eq 0 ]; then
    path='.'
else 
    path=$1
fi

find $path -type f -follow -print|xargs ls -l
