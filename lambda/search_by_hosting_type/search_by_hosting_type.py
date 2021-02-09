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

def get_monthly_price_value(monthly_price):
    """
    Returns the threshold value to limit the plan price

    :param monthly_price: The HTML form monthly_price value
    :return: Max MonthlyPrice to search for
    """

    if monthly_price == "Price0":
        return 0
    elif monthly_price == "Price5":
        return 5
    elif monthly_price == "Price10":
        return 10
    elif monthly_price == "Price25":
        return 25
    else:
        return 9999


class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
      if isinstance(o, decimal.Decimal):
        if o % 1 > 0:
          return float(o)
        else:
          return int(o)
      return super(DecimalEncoder, self).default(o)


def get_hosting_list(table_name, out, hosting_type, max_price):
    """
    Gets the list of hosting plans.

    :param table_name: dynamoDB table to use
    :param out: the lambda return variable, to be updated accordingly
    :param hosting_type: the HostingType GSI to search by. Case sensitive. e.g. Wordpress
    :param max_price: max price for the plan to search for.
        TODO: filter ?
    
    :return: The list of hosting plans
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
        # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/customizations/dynamodb.html#dynamodb-conditions
        response = table.query(
            IndexName='HostingType-index',
            KeyConditionExpression=
                Key('HostingType').eq(hosting_type) & Key('PaymentMonthMin').lte(max_price)
        )

        # We need to convert from decimal (dynamodb) to float (json compatible)
        # Lambda response has to be an object compliant with json.dumps
        #   https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
        out['body'] = json.dumps({
            'message': response['Items']
        }, cls=DecimalEncoder)

        out['statusCode'] = response['ResponseMetadata']['HTTPStatusCode']
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


def scan_hosting_list(table_name, out, max_price):
    """
    Gets the whole list of hosting plans.

    :param table_name: dynamoDB table to use
    :param out: the lambda return variable, to be updated accordingly
    :param max_price: max price for the plan to search for.
        TODO: filter ?
    
    :return: The list of hosting plans
    """

    # Using a local docker network to access to dynamodb container by its name
    dynamodb = boto3.resource('dynamodb', endpoint_url="http://dynamodb:8000")
    table = dynamodb.Table(table_name)
    scan_kwargs = {
        'FilterExpression': Key('PaymentMonthMin').lte(max_price)
    }
    done = False
    start_key = None

    try:
        # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.04.html#GettingStarted.Python.04.Scan
        while not done:
            if start_key:
                scan_kwargs['ExclusiveStartKey'] = start_key
            response = table.scan(**scan_kwargs)
            start_key = response.get('LastEvaluatedKey', None)
            done = start_key is None

        # We need to convert from decimal (dynamodb) to float (json compatible)
        # Lambda response has to be an object compliant with json.dumps
        #   https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
        out['body'] = json.dumps({
            'message': response['Items']
        }, cls=DecimalEncoder)

        out['statusCode'] = response['ResponseMetadata']['HTTPStatusCode']
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
    monthly_price=body['MonthlyPrice']
    monthly_price_value=get_monthly_price_value(monthly_price)

    if hosting_type == "Todos":
        out, response = scan_hosting_list(table_name, out, monthly_price_value)
    else:
        ## Query DynamoDB
        out, response = get_hosting_list(table_name, out, hosting_type, monthly_price_value) 

    return out
