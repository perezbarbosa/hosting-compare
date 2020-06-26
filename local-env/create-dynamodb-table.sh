#!/usr/bin/env bash

# Afaik, you only have to define the attributes you will use for partition (HASH) and sort (RANGE) key
#
# Reference: https://docs.aws.amazon.com/cli/latest/reference/dynamodb/create-table.html
# Design: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-general-nosql-design.html
# Hash and Range key howto: https://stackoverflow.com/questions/27329461/what-is-hash-and-range-primary-key
#   A key schema element has to be a scalar (S,N,B), top-level attribute
#   https://docs.aws.amazon.com/es_es/amazondynamodb/latest/APIReference/API_KeySchemaElement.html
#

TABLE_NAME="HostingList"
PARTITION_NAME="Provider"
PARTITION_TYPE="S"
SORT_NAME="MinPriceMonth"
SORT_TYPE="N"

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

aws dynamodb scan --table-name $TABLE_NAME --endpoint-url http://localhost:8000