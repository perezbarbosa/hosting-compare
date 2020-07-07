import boto3
from boto3.dynamodb.conditions import Key
import json
from pprint import pprint
import sys


def init_return_variable():
    out = {}
    out['headers'] = {
        'Content-Type': 'application/json',
        }
    out['statusCode'] = 200
    out['body'] = {
        'message': 'I have been initialized',
    }
    return out


def get_hosting_list(out, hosting_type):
    # Using a local docker network to access to dynamodb container by its name
    dynamodb = boto3.resource('dynamodb', endpoint_url="http://dynamodb:8000")
    table = dynamodb.Table('HostingList')

    try:
        # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.04.html
        # https://stackoverflow.com/questions/35758924/how-do-we-query-on-a-secondary-index-of-dynamodb-using-boto3
        response = table.query(
            IndexName='HostingType-index',
            KeyConditionExpression=Key('HostingType').eq(hosting_type)
        )
        out['body'] = {
            'message': response['Items'],
        }
    except:
        print("Unexpected error")
        pprint(sys.exc_info())
        out['statusCode'] = 500
        out['body'] = {
            'message': 'Cannot query the database',
        }
    
    return out, response['Items']


def handler(event, context):
    """ Loads sample data into local database

        Expects to receive a payload with at least a HostingType and optionally filters to apply.
        No need to include the "filter" key at all if no filters are being send.
        {
            "HostingType": "string",
            "Filter": {
                "Attribute1": "value1",
                "Attribute2": "value2",
                ...
                "AttributeN": "valueN"
            }
        }
    """

    out = init_return_variable()

    ## Get data from json 

    if event['body']:
        body = json.loads(event['body'])

    hosting_type=body['HostingType']

    if "Filter" in body:
        #TODO
        pass

    ## Query DynamoDB
    out, response = get_hosting_list(out, hosting_type) 

    return out
