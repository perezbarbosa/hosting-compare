import boto3
import json
from pprint import pprint
import sys

def handler(event, context):
    """ Loads sample data into local database

        Expects to receive a payload with a list of json objects
        formatted as dynamodb.put_item expects
            https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html#DynamoDB.Client.put_item
    """

    if event['body']:
        body = json.loads(event['body'])

    out = {}
    out['headers'] = {
        'Content-Type': 'application/json',
        }

    # Using a local docker network to access to dynamodb container by its name
    dynamodb = boto3.client('dynamodb', endpoint_url='http://dynamodb:8000')

    try:
        for entry in body:
            pprint(entry)
            response = dynamodb.put_item(
                TableName='HostingList',
                Item=entry,
            )
            out['statusCode'] = 200
            out['body'] = {
                'message': response,
            }
    except:
        print("Unexpected error")
        pprint(sys.exc_info())
        out['statusCode'] = 500
        out['body'] = {
            'message': 'Unexpected error',
        }

    return out
