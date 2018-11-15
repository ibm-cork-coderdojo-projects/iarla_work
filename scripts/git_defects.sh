#!/bin/bash

#Inputs
REPO=ibm-cork-coderdojo-projects/iarla_work
USERNAME=iarla.crewe@gmail.com
TOKEN=ab141b89a1e3760b739331ff4e38b1a2a86e36f6
#REPO=${1:? Repo required}
#USERNAME=${2:? Username required}
#TOKEN=${3:? Token required}
LABELS=("git" "docker" "verified")

#Variables
total_issues=0

#Constant varialbes
VERIFIED_RANGE_WEEKS=2
VERIFIED_NAME="verified"
FILE_NAME="defects.csv"
HTML_NAME="defects.html"

function get_date {
  #Gets the date x weeks ago
  date --date="${VERIFIED_RANGE_WEEKS} week ago" "+20%y-%m-%dT%H:%M:%SZ"
}

#Get amount of issues with specified labels and output results into a .csv file
echo -n > $FILE_NAME
for i in ${!LABELS[@]}; do
    url="https://api.github.com/search/issues?q=repo:$REPO+label:${LABELS[$i]}+is:open"
    if [ "${LABELS[$i]}" = "${VERIFIED_NAME}" ]; then
        url=${url}+since:$(get_date)
    fi
    label_count=$(curl -s -u $USERNAME:$TOKEN -H "Accept: all" "${url}" | jq '.total_count')
    let "total_issues = $total_issues + $label_count"
    echo "${LABELS[$i]},$label_count" >> $FILE_NAME
done
echo "Total,${total_issues}" >> $FILE_NAME

#Output the .csv file into a html file to create table
echo "<h2>Issue Table for:  <em>${REPO}</em></h2><table border="3" cellspacing="2" cellpadding="7">" > $HTML_NAME ;
while read INPUT ; do
      echo "<tr><td><b>${INPUT//,/</b></td><td>}</td></tr>" >> $HTML_NAME ;
done < $FILE_NAME ;
echo "</table>" >> $HTML_NAME
