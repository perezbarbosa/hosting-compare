#!/usr/bin/env bash

# Afaik, you only have to define the attributes you will use for partition (HASH) and sort (RANGE) key
#
# Reference: https://docs.aws.amazon.com/cli/latest/reference/dynamodb/create-table.html
# Design: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-general-nosql-design.html
# Hash and Range key howto: https://stackoverflow.com/questions/27329461/what-is-hash-and-range-primary-key
#   A key schema element has to be a scalar (S,N,B), top-level attribute
#   https://docs.aws.amazon.com/es_es/amazondynamodb/latest/APIReference/API_KeySchemaElement.html
#


# PartitionKey: The HostingId, which is a unique value composed by lower(provider)_lower(hostingType)_lower(hosting_plan)
# SortKey: The MinPaymentMonth. I had to copy the min monthly payment value for the plan and move it to the top level to be used as key
#
# Access Pattern: GetHostingPlan(HostingId)
#    Description: get the entry details given the HostingId
#    Use Case: a user wants to show all the details for a specific plan  

TABLE_NAME="HostingList"
PARTITION_NAME="HostingId"
PARTITION_TYPE="S"
SORT_NAME="MinPaymentMonth"
SORT_TYPE="N"

echo "**** CREATE-TABLE *****"
aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions \
        AttributeName=$PARTITION_NAME,AttributeType=$PARTITION_TYPE \
        AttributeName=$SORT_NAME,AttributeType=$SORT_TYPE \
    --key-schema \
        AttributeName=$PARTITION_NAME,KeyType=HASH \
        AttributeName=$SORT_NAME,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --endpoint-url http://localhost:8000

# GSI Partition Key: HostingType, e.g. WordPress, VPS, dedicated, etc.
# GSI Sort Key: The MinPaymentMonth. I had to copy the min monthly payment value for the plan and move it to the top level to be used as key
#
# Access Pattern: SearchByHostingType(HostingType)
#    Description: get all entries with HostingType=HostingType sorted by MinPaymentAmount
#    Use Case: a user wants to compare hostings. We will also apply filters here.

GSI_HOSTINGTYPE_PARTITION_NAME="HostingType"
GSI_HOSTINGTYPE_PARTITION_TYPE="S"
GSI_HOSTINGTYPE_SORT_NAME="MinPaymentMonth"
GSI_HOSTINGTYPE_SORT_TYPE="N"
GSI_HOSTINGTYPE_KEY=[{AttributeName=HostingType,KeyType=HASH},{AttributeName=MinPaymentMonth,KeyType=RANGE}]
# TODO: Use projection INCLUDE instead of ALL to include only the attr we need
GSI_HOSTINGTYPE_ATTR=["Provider","HostingPlan","WebNumber","Payment","Currency"]

echo "**** CREATE-GSI $GSI_HOSTINGTYPE_PARTITION_NAME *****"
aws dynamodb update-table \
    --table-name $TABLE_NAME \
    --attribute-definitions \
        AttributeName=$GSI_HOSTINGTYPE_PARTITION_NAME,AttributeType=$GSI_HOSTINGTYPE_PARTITION_TYPE \
        AttributeName=$GSI_HOSTINGTYPE_SORT_NAME,AttributeType=$GSI_HOSTINGTYPE_SORT_TYPE \
    --global-secondary-index-updates \
        "[{\"Create\":{\"IndexName\": \"$GSI_HOSTINGTYPE_PARTITION_NAME-index\",\"KeySchema\":[{\"AttributeName\":\"$GSI_HOSTINGTYPE_PARTITION_NAME\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"$GSI_HOSTINGTYPE_SORT_NAME\",\"KeyType\":\"RANGE\"}], \
        \"ProvisionedThroughput\": {\"ReadCapacityUnits\": 10, \"WriteCapacityUnits\": 5 },\"Projection\":{\"ProjectionType\":\"ALL\"}}}]" \
    --endpoint-url http://localhost:8000

aws dynamodb scan --table-name $TABLE_NAME --endpoint-url http://localhost:8000