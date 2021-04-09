#!/bin/bash
#Create simple json, nested json is not supported
#Example usage
#sh simpleJson.sh "key=value" "DB_URL=192.168.0.100" "DB_USERNAME=qwerty


#simple validation
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

echo "{" > config.json
i=1;
for var in "$@"
do
    key=` echo $var | awk -F "=" '{print $1}'`
    value=` echo $var | awk -F "=" '{print $2}'`
    if [ $i -eq $# ]; then
        echo '  "'$key'":"'$value'"' >> config.json
    else 
        echo '  "'$key'":"'$value'",' >> config.json
        i=$((i+1))
    fi
done
echo "}" >> config.json