#!/bin/bash

# Get X-Candidate-Id from TXT DNS record
subdomain=candiharvest.infomanihack.ch
x_candidate_id=$(dig -t txt ${subdomain} | grep -o -P '(?<=IN.TXT.").*(?=")') #or = $(dig +short ${subdomain} txt)
              
# Get and print content result
echo $("`wget -qO- --header='X-Candidate-Id:'${x_candidate_id} https://${subdomain}`")