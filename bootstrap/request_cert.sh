#!/bin/bash
#

set -e
# The temporary environment has a DNS zone assigned to it.

DNS_ZONE=$(aws route53 list-hosted-zones)
ZONE_ID=$(echo $DNS_ZONE | jq -r .HostedZones[0].Id)
echo "DNS Zone ID: $ZONE_ID"
# DNS name ends with a ".", so we need to get rid of that
DNS_NAME=$(echo $DNS_ZONE | jq -r .HostedZones[0].Name | sed -e "s/\.$//")
echo "DNS Name: $DNS_NAME"
echo
echo "========================================"
echo

# Request the certificate, and convert the response into an ARN
REQUEST_OUTPUT=$(aws acm request-certificate --domain-name $DNS_NAME --validation-method DNS)
echo $REQUEST_OUTPUT
CERT_ARN=$(echo $REQUEST_OUTPUT | jq -r .CertificateArn)
echo "Certificate ARN: $CERT_ARN"
echo
echo "========================================"
echo

# We still need to verify.  Grab the information needed to do that
DESCRIBE_OUTPUT=$(aws acm describe-certificate --certificate-arn $CERT_ARN)
RR_NAME=$(echo $DESCRIBE_OUTPUT | jq -r .Certificate.DomainValidationOptions[0].ResourceRecord.Name)
RR_TYPE=$(echo $DESCRIBE_OUTPUT | jq -r .Certificate.DomainValidationOptions[0].ResourceRecord.Type)
RR_VALUE=$(echo $DESCRIBE_OUTPUT | jq -r .Certificate.DomainValidationOptions[0].ResourceRecord.Value)

cat << EOF > changes.json
    {
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "$RR_NAME",
                    "Type": "$RR_TYPE",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "$RR_VALUE"
                        }
                    ]
                }
            }
        ]
    }
EOF

aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://changes.json && rm changes.json && echo "requested record sets"

# Check to see if it has been validated (this can take 30 seconds to 15 minutes depending on your luck)

echo
echo "========================================"
echo
echo "If you get an error below, you can check cert status with:"
echo
echo "aws acm get-certificate --certificate-arn $CERT_ARN"
echo
aws acm get-certificate --certificate-arn $CERT_ARN


