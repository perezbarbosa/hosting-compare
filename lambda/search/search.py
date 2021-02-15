import boto3
import decimal
import json
import pymysql
from pprint import pprint
import os
import sys


DB_ATTRIBUTES = ['Currency',
    'DatabaseNumber',
    'DatabaseSize',
    'DiskSize',
    'DiskType',
    'DomainIncluded',
    'DomainSubdomain',
    'DomainsParked',
    'HostingPlan',
    'HostingType',
    'PartitionKey',
    'PaymentMonthMin',
    'Provider',
    'SslCertificate',
    'WebNumber'] 


def get_environment_variables():
    """
    Gets the environment variables
    
    :return: a dictionary 
    """
    envs = {}
    try:
        #envs['mysql_host'] = os.environ['MYSQL_HOST']
        #envs['mysql_db'] = os.environ['MYSQL_DB']
        #envs['mysql_user'] = os.environ['MYSQL_USER']
        #envs['mysql_pass'] = os.environ['MYSQL_PASS']
        envs['mysql_host'] = "mariadb"
        envs['mysql_db'] = "quehosting" 
        envs['mysql_user'] = "root"
        envs['mysql_pass'] = "quehosting.es" 
    except:
        print("ERROR: Unexpected error: Could not get environment")
        pprint(sys.exc_info())
        sys.exit()

    return envs


def init_return_variable():
    """
    Initializes the lambda return variable
    
    :return: the initialized return variable
    """
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


def validate(data):
    """
    Validates that data included in 'data' follows the format and is not including weird stuff
    This means we need to know exactly what data is going to be include there.
    Current filter feature includes the following:
    - HostingType
    - MonthlyPrice

    :return: same data, in a dictionary, validated and transformed when needed
    """
    # TODO
    data_ready = {}
    data_ready['HostingType'] = data['HostingType']
    data_ready['MonthlyPrice'] = get_monthly_price_value(data['MonthlyPrice'])
    return data_ready


def mysql_connect(host, db, user, password):
    """
    Connects to MySQL database
    https://docs.aws.amazon.com/lambda/latest/dg/services-rds-tutorial.html

    :return: the db connection object
    """
    try:
        conn = pymysql.connect(
            host=host,
            user=user,
            password=password,
            database=db
        )
    except pymysql.MySQLError as e:
        print("ERROR: Unexpected error: Could not connect to the database LALALALA")
        print(host, user, password, db)
        pprint(sys.exc_info())
        sys.exit()
    return conn


def prepare_query(data):
    """
    Prepares the SQL query according to data.
    Current filter feature includes the following:
    - HostingType
    - MonthlyPrice

    There's no need to worry about data transformations as were done by 'validate' method

    :return: the query ready to be executed
    """
    sql = """SELECT {} 
        FROM hosting_plan
        WHERE HostingType = '{}'
        AND PaymentMonthMin <= {}
        ORDER BY PaymentMonthMin ASC
        """.format(
            ", ".join(DB_ATTRIBUTES),
            data['HostingType'],
            data['MonthlyPrice']
        )

    pprint(sql)

    return sql


def convert_to_json(item):
    """
    Converts an item, containing a SQL query row result, into a json
    compatible with the lambda handler response

    The strategy is to create a dictionary with the column names as keys
    and the query results as values

    :return: a json compatible with json.dumps 
    """
    if len(DB_ATTRIBUTES) != len(item):
        sys.exit("Unexpected error preparing results")
    
    result = {}
    for i in range(len(item)):
        result[DB_ATTRIBUTES[i]] = item[i]
    
    return result


class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
      if isinstance(o, decimal.Decimal):
        if o % 1 > 0:
          return float(o)
        else:
          return int(o)
      return super(DecimalEncoder, self).default(o)


def get_hosting_list(out, data):
    """
    Gets the list of hosting plans.

    :param out: the lambda return variable, to be updated accordingly
    :param data: a dictionary including all data used to filter
    
    :return: The list of hosting plans
    """

    envs = get_environment_variables()
    conn = mysql_connect(envs['mysql_host'], envs['mysql_db'], envs['mysql_user'], envs['mysql_pass'])
    sql = prepare_query(data)
    try:
        # https://docs.aws.amazon.com/lambda/latest/dg/services-rds-tutorial.html#vpc-rds-deployment-pkg
        with conn.cursor() as cursor:
            cursor.execute(sql)
            response = []
            for row in cursor:
                # Lambda response has to be an object compliant with json.dumps
                #   https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
                response.append(convert_to_json(row)) 

        out['body'] = json.dumps({
            'message': response
        }, cls=DecimalEncoder)

        out['statusCode'] = '200'

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
    """ 
    Queries the database to get the list of hosting plans based on the filter included in the body         
    """

    out = init_return_variable()

    ## Get data from json 
    if event['body']:
        pprint(event['body'])
        body = json.loads(event['body'])

    filter_data = validate(body)

    out, response = get_hosting_list(out, filter_data) 

    pprint(out)

    return out
