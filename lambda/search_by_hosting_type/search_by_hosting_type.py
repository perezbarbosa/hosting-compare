import boto3
from boto3.dynamodb.conditions import Key
import decimal
import json
from pprint import pprint
import os
import sys


def get_environment_variables():
    """Gets the environment variables"""
    if os.environ['TABLE_NAME']:
        table_name = os.environ['TABLE_NAME']
    else:
        table_name = 'HostingList'
    return table_name


def init_return_variable():
    """Initializes the lambda return variable"""
    out = {}
    out['headers'] = {
        'Content-Type': 'application/json',
        # TODO: This CORS policy is just for local testing. Remember to remove it for prod!
        'Access-Control-Allow-Origin':'*',
        }
    out['statusCode'] = 200
    out['body'] = {
        'message': 'I have been initialized',
    }
    return out

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
      if isinstance(o, decimal.Decimal):
        if o % 1 > 0:
          return float(o)
        else:
          return int(o)
      return super(DecimalEncoder, self).default(o)


def get_hosting_list(table_name, out, hosting_type):
    """Gets the list of hosting plans.

    Args:
        table_name: The DynamoDB table to use
        out: The lambda return variable, to be updated accordingly
        hosting_type: The HostingType GSI to search by. Case sensitive. e.g. Wordpress
        TODO: filter ?
    
    Returns:
        The list of hosting plans
    """

    # DEBUG
    # pprint("1: {} 2: {} 3: {}".format(table_name,out,hosting_type))

    # Using a local docker network to access to dynamodb container by its name
    dynamodb = boto3.resource('dynamodb', endpoint_url="http://dynamodb:8000")
    table = dynamodb.Table(table_name)

    # DEBUG
    # pprint(table)

    try:
        # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.04.html
        # https://stackoverflow.com/questions/35758924/how-do-we-query-on-a-secondary-index-of-dynamodb-using-boto3
        response = table.query(
            IndexName='HostingType-index',
            KeyConditionExpression=Key('HostingType').eq(hosting_type)
        )

        # Lambda has to return objets that can be serialized by json.dumps, otherwise lambda will return an error
        # https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html


        # DEBUG
        testa = [{ "A": "B" }]
        pprint("AAAAAA")
        pprint(json.dumps(response['ResponseMetadata']))
        pprint("AAAAAA")

        out['statusCode'] = response['ResponseMetadata']['HTTPStatusCode']
        out['body'] = json.dumps({
            # We need to convert from decimal (dynamodb) to float (json compatible)
            #   Lambda response has to be an object compliant with json.dumps
            #'message': testa,
            'message': response['Items']
        }, cls=DecimalEncoder)
        #out['headers'] = {**out['headers'], **response['ResponseMetadata']['HTTPHeaders']}

        pprint("HEADERS")
        pprint(out['headers'])
    except:
        print("Unexpected error")
        pprint(sys.exc_info())
        out['statusCode'] = 500
        out['body'] = {
            'message': 'Cannot query the database',
        }
    
    return out, response


def handler(event, context):
    """ Queries the database to get the list of hosting plans
            ACCESS PATTERN "Search By Hosting Type"
                GSI Partition Key = Hosting Type
                GSI Sort Key      = min price

        Expects to receive a payload with at least a HostingType and optionally filters to apply.
        No need to include the "filter" key at all if no filters are being send.
        TODO: What about "price between X and Y"???
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

    table_name = get_environment_variables()
    out = init_return_variable()

    ## Get data from json 

    if event['body']:
        pprint(event['body'])
        body = json.loads(event['body'])

    hosting_type=body['HostingType']

    if "Filter" in body:
        #TODO
        pass

    ## Query DynamoDB
    out, response = get_hosting_list(table_name, out, hosting_type) 

    return out
