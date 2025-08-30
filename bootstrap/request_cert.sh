#!/bin/bash
#

# The temporary environment has a DNS zone assigned to it.

DNS_ZONE=$(aws route53 list-hosted-zones)
ZONE_ID=$(echo $DNS_ZONE | jq -r .HostedZones[0].Id)

# DNS name ends with a ".", so we need to get rid of that
DNS_NAME=$(echo $DNS_ZONE | jq -r .HostedZones[0].Name | sed -e "s/\.$//")

# Request the certificate, and convert the response into an ARN
REQUEST_OUTPUT=$(aws acm request-certificate --domain-name $DNS_NAME --validation-method DNS)
CERT_ARN=$(echo $REQUEST_OUTPUT | jq -r .CertificateArn)

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

aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://changes.json
rm changes.json

# Check to see if it has been validated (this can take 30 seconds to 15 minutes depending on your luck)

aws acm get-certificate --certificate-arn $CERT_ARN

echo "You can check cert status with:"
echo
echo "aws acm get-certificate --certificate-arn $CERT_ARN"
echo

