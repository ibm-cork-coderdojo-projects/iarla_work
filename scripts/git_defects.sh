#!/bin/bash
: '
This script takes a github repo, username, token and labels, then find the total number of 
issues with each label. Only verified issues (ones with the label verified) that have been
updated in the last 2 weeks are shown.
1) Get inputs (1st parameter = username, 2nd = token)
2) Get repo and labels info from repo.txt files
3) Querry githup api for total amount of issues with each label in each repo
4) Output results and total to a .csv file for each repo
5) Output all results for every repo and total into tables in a .html file
'

#Inputs
USERNAME=${1:? Username required}
TOKEN=${2:? Token required}

#Constant varialbes
VERIFIED_RANGE_WEEKS="2"
VERIFIED_NAME="Verified"
HTML_NAME="defects.html"

#Get the date x weeks ago
function get_date {
    date --date="${VERIFIED_RANGE_WEEKS} week ago" "+20%y-%m-%dT%H:%M:%SZ"
}

#Get files in directory
echo -n > $HTML_NAME
counter=0
while read config_file; do
    #Set the .csv output file
    file_name="defects${counter}.csv"
    echo -n > $file_name
    
    #Get repo and labels from .txt file
    . ./$config_file
    labels=($labels_string)

    #Get amount of issues with specified labels and output results into a .csv file
    for i in ${!labels[@]}; do
        url="https://api.github.ibm.com/repos/${repo}/issues?labels=${labels[$i]}&is:open"
        #If issue = verified, change url & output to check if it's been updated recently
        updated_recently=""
        if test "${labels[$i]#*$VERIFIED_NAME}" != "${labels[$i]}"; then
            url="https://api.github.ibm.com/repos/$repo/issues?labels=${labels[$i]}&since:$(get_date)"
            updated_recently=" (In the last ${VERIFIED_RANGE_WEEKS} weeks)"
        elif test "${labels[$i]#*,$VERIFIED_NAME}" != "${labels[$i]}"; then
            url="https://api.github.ibm.com/repos/$repo/issues?labels=${labels[$i]}&since:$(get_date)"
            updated_recently=" (In the last ${VERIFIED_RANGE_WEEKS} weeks)"
        fi
        #Use jquery to get the total amount of issues with each label, then output result to file
        label_count=$(curl -s -u $USERNAME:$TOKEN -H "Accept: all" "${url}" | jq length)
        labels[$i]=${labels[$i]//','/$' & '}
        labels[$i]=${labels[$i]//'%20'/' '}
        echo "${labels[$i]}${updated_recently},$label_count" >> $file_name
    done
    #Output total to file
    echo "Total,$(curl -s -u $USERNAME:$TOKEN https://api.github.ibm.com/repos/$repo/issues | jq length)" >> $file_name

    #Output the .csv file into a .html file to create a table
    echo "<h2>Issue Table for:  <em>${repo}</em></h2><table border="3" cellspacing="2" cellpadding="7">" >> $HTML_NAME ;
    while read INPUT ; do
        echo "<tr><td><b>${INPUT//,/</b></td><td>}</td></tr>" >> $HTML_NAME ;
    done < $file_name ;
    echo "</table>" >> $HTML_NAME

    ((counter++))
done <<< "$(ls -1 *.txt)"