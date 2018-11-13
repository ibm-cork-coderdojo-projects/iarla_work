#!/bin/bash

username=$1
appkey=$2

repo=https://api.github.ibm.com/search/issues?q=repo:security-secops/IBM-Security-Cloud
file_name=defects_infra.csv
html_name=defect_infra.html

sev1=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect+label:Severity1+is:open")
echo "$sev1" | grep total_count | sed -e 's/"total_count": /sev1,/g' > $file_name

sev2=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect+label:Severity2+is:open")
echo "$sev2" | grep total_count | sed -e 's/"total_count": /sev2,/g' >> $file_name

infra=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect+label:%22Infrastructure%20Services%22+is:open")
echo "$infra" | grep total_count | sed -e 's/"total_count": /infra,/g' >> $file_name

sev3=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect+label:Severity3+is:open")
echo "$sev3" | grep total_count | sed -e 's/"total_count": /sev3,/g' >> $file_name

sev4=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect+label:Severity4+is:open")
echo "$sev4" | grep total_count | sed -e 's/"total_count": /sev4,/g' >> $file_name

eft=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:%22EFT%20Blocker%22+is:open")
echo "$eft" | grep total_count | sed -e 's/"total_count": /eft,/g' >> $file_name

res=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect+label:Resolved+is:open")
echo "$res" | grep total_count | sed -e 's/"total_count": /resolved,/g' >> $file_name

ver=$(curl -s -u $username:$appkey -H "Accept: all" "${repo}""+label:defect++label:Verified+is:closed")
echo "$ver" | grep total_count | sed -e 's/"total_count": /verified,/g' >> $file_name

echo "<table>" > $html_name ;
while read INPUT ; do
      echo "<tr><td>${INPUT//,/</td><td>}</td></tr>" >> $html_name ;
done < $file_name ;
echo "</table>" >> $html_name
