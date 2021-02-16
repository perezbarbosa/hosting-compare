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


def validate_and_transform(data):
    """
    Validates that data included in 'data' follows the format and is not including weird stuff
    In order to do that we are iterating throught all items and validating no weird stuff is
    there. Weird data is discarted.
    { POST: All keys are matching table attribute names }

    There are exceptional fields that require extra transformation

    Current filter feature includes the following:
    - HostingType
    - MonthlyPrice

    :param data: the input form dictionary
    :return: only valid data (and keys are matching table attribute names), in a dictionary, transformed when needed. 
    """
    data_ready = {}
    for key, value in data.items():
        # Only if has no special characters, we include it
        if value.isalnum():
            # MonthlyPrice is actually checking the PaymentMonthMin table attribute
            if key == 'MonthlyPrice':
                data_ready['PaymentMonthMin'] = get_monthly_price_value(data['MonthlyPrice'])
            # HostingType = all -> means no filter
            elif key in ['HostingType','DomainIncluded'] and value == 'Todos':
                continue
            # By default, we just include the item
            else:
                data_ready[key] = value
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


def append_query_condition(column):
    """
    Prepares a query condition based on the attribute
    As we have no way to know what kind of condition (lt, eq, like, etc.) we
    need, we are creating a mapping here

    :param column: the column name
    :return out: a string to append to the query condition
    """

    if column in ["PaymentMonthMin"]:
        out = column + " <= %s"
    elif column in ["HostingType", "DomainIncluded"]:
        out = column + " = %s"
    else:
        # TODO
        sys.exit("Unexpected error appending condition {}".format(column))
    
    return out

def prepare_query(data):
    """
    Prepares the SQL query according to data.
    {PRE: data includes valid data and all keys are matching table attributes}

    :param data: dictionary including all fields to filter
    :return: the query ready to be executed
    """

    # TODO this is a default ORDER BY
    sort = "PaymentMonthMin"

    sql = """SELECT {}
        FROM hosting_plan
        """.format(
            ", ".join(DB_ATTRIBUTES)
        )

    args = []

    where = False
    for key, value in data.items():
        if where == False:
            sql = sql + " WHERE " + append_query_condition(key)
            where = True
        else:
            sql = sql + " AND " + append_query_condition(key)
        args.append(value)
  
    sql = sql + " ORDER BY " + sort + " ASC"

    pprint(sql)
    pprint(args)

    return sql, args


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
    :param data: a dictionary including all data used to filter, already validated and transformed
    
    :return: The list of hosting plans
    """

    envs = get_environment_variables()
    conn = mysql_connect(envs['mysql_host'], envs['mysql_db'], envs['mysql_user'], envs['mysql_pass'])
    sql, args = prepare_query(data)
    try:
        # https://docs.aws.amazon.com/lambda/latest/dg/services-rds-tutorial.html#vpc-rds-deployment-pkg
        with conn.cursor() as cursor:
            cursor.execute(sql, args)
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
        pprint("[DEBUG] -- body here")
        pprint(body)
        pprint("[DEBUG] -- end body")

    filter_data = validate_and_transform(body)

    out, response = get_hosting_list(out, filter_data) 

    pprint(out)

    return out
