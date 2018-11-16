#!/bin/bash
: '
This script takes a github repo, username, token and labels, then find the total number of 
issues with each label. Only verified issues (ones with the label verified) that have been
updated in the last 2 weeks are shown.
1) Get inputs (1st parameter = repo, 2nd = username, 3rd = token)
2) Get all the labels for issues in the repo
3) Querry githup api for total amount of issues with each label
4) Output results and total to a .csv file
5) Output results and total to a table in a .html file
'

#Inputs
REPO=${1:? Repo required}
USERNAME=${2:? Username required}
TOKEN=${3:? Token required}

#Variables
total_issues=0

#Constant varialbes
VERIFIED_RANGE_WEEKS="0"
VERIFIED_NAME="git"
FILE_NAME="defects.csv"
HTML_NAME="defects.html"

#Get the date x weeks ago
function get_date {
    date --date="${VERIFIED_RANGE_WEEKS} week ago" "+20%y-%m-%dT%H:%M:%SZ"
}

#Get all the labels in the repo
counter=0
label_length=$(curl -s -u $USERNAME:$TOKEN "https://api.github.com/repos/$REPO/labels" | jq length)
while [ $counter -le $label_length ]; do
    labels[$counter]=$(curl -s -u $USERNAME:$TOKEN "https://api.github.com/repos/$REPO/labels" | jq ".[$counter].name")
    ((counter++))
done

#Get amount of issues with specified labels and output results into a .csv file
echo -n > $FILE_NAME
for i in ${!labels[@]}; do
    url="https://api.github.com/search/issues?q=repo:$REPO+label:${labels[$i]}+is:open"
    #CIf issue = verified, change url & output to check if it's been updated recently
    updated_recently=""
    if [ "${labels[$i]}" = "${VERIFIED_NAME}" ]; then
        url="https://api.github.com/repos/$REPO/issues?labels=${VERIFIED_NAME}&since:$(get_date)"
        updated_recently=" (In the last ${VERIFIED_RANGE_WEEKS} weeks)"
    fi
    #Use jquery to get the total amount of issues with each label, then output result to file
    label_count=$(curl -s -u $USERNAME:$TOKEN -H "Accept: all" "${url}" | jq '.total_count')
    echo "${labels[$i]}${updated_recently},$label_count" >> $FILE_NAME
    #Add amount to total
    let "total_issues = $total_issues + $label_count"
done
#Output total to file
echo "Total,${total_issues}" >> $FILE_NAME

#Output the .csv file into a .html file to create a table
echo "<h2>Issue Table for:  <em>${REPO}</em></h2><table border="3" cellspacing="2" cellpadding="7">" > $HTML_NAME ;
while read INPUT ; do
    echo "<tr><td><b>${INPUT//,/</b></td><td>}</td></tr>" >> $HTML_NAME ;
done < $FILE_NAME ;
echo "</table>" >> $HTML_NAME