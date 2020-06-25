import json

def handler(event, context):
    message = 'Hello {} {}!'.format(event['first_name'], 
                                    event['last_name'])   

    # By default, AWS SAM uses Proxy Integration and expects the response 
    # from your Lambda function to include one or more of the following: 
    # statusCode, headers, or body
    #
    # https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-start-api.html

    out = {}
    out['statusCode'] = 200
    out['headers'] = {
        'Content-Type': 'application/json',
        }
    out['body'] = {
        'message': message,
    }

    return out
