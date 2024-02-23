#!/usr/bin/env python

import requests, dns.resolver

# Get X-Candidate-Id from TXT DNS record
subdomain = "candiharvest.infomanihack.ch"
resolver = dns.resolver.Resolver()
txt_record = resolver.resolve(subdomain, "TXT")
x_candidate_id = txt_record.response.answer[0][0].to_text()[1:-1]

# Get and print content result
response = requests.get("https://"+subdomain, headers={'X-Candidate-Id': x_candidate_id})
print(response.content.rstrip())

