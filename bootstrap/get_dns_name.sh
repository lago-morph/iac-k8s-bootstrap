#!/bin/bash
#

DNS_ZONE=$(aws route53 list-hosted-zones)
ZONE_ID=$(echo $DNS_ZONE | jq -r .HostedZones[0].Id)
echo "DNS Zone ID: $ZONE_ID"
# DNS name ends with a ".", so we need to get rid of that
DNS_NAME=$(echo $DNS_ZONE | jq -r .HostedZones[0].Name | sed -e "s/\.$//")
echo "DNS Name: $DNS_NAME"
echo $DNS_NAME > ~/DNS_NAME
echo
