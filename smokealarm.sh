#!/bin/bash

# A small bash script to take the output of SmokePing's alerting function, run MTR,
# and send the alert with MTR results via a webhook to a predefined Slack web address. 
# Author: Nick Plunkett
# Created: 2024-01
# Updated: [Current Date]

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 name-of-alert target loss-pattern rtt-pattern hostname"
    exit 1
fi

webhook_url=""
name_of_alert=$1
target=$2
loss_pattern=$3
rtt_pattern=$4
hostname=$5

# Run MTR and capture the output
mtr_output=$(mtr -n -c 10 -r "$target")

# Escape special characters in the MTR output for JSON
mtr_output_escaped=$(echo "$mtr_output" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

payload='{
    "text": "*New Alert* :alarm_clock:",
    "attachments": [
        {
            "color": "#FF5733",
            "fields": [
                {"title": "Name of Alert", "value": "'"$name_of_alert"'", "short": true},
                {"title": "Target", "value": "'"$target"'", "short": true},
                {"title": "Loss Pattern", "value": "'"$loss_pattern"'", "short": true},
                {"title": "RTT Pattern", "value": "'"$rtt_pattern"'", "short": true},
                {"title": "Hostname", "value": "'"$hostname"'", "short": true}
            ]
        },
        {
            "color": "#36a64f",
            "title": "MTR Results",
            "text": "```\n'"$mtr_output_escaped"'\n```"
        }
    ]
}'

response=$(curl -s -X POST -H "Content-type: application/json" --data "$payload" "$webhook_url")

if [[ $? -ne 0 ]]; then
    echo "Error executing curl command"
    exit 1
fi

echo "Response from Slack: $response"
