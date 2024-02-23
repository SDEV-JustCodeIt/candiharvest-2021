<?php

# Get X-Candidate-Id from TXT DNS record
$subdomain = "candiharvest.infomanihack.ch";
$txt_record = dns_get_record($subdomain, DNS_TXT);
$x_candidate_id = $txt_record[0]['txt'];

# Get and print content result
$context = stream_context_create(array(
        'http'=>array(
        'method'=>"GET",
        'header'=>"X-Candidate-Id: $x_candidate_id\r\n" .
                "User-Agent: Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.102011-10-16 20:23:10\r\n")));
$response = file_get_contents("https://$subdomain", false, $context);
print_r($response);

?>
