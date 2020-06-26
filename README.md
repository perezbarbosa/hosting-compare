# hosting-compare


## Mockup
https://wireframepro.mockflow.com/

## Local env

### Requisites

- Docker
- [AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) to enable API Gateway and Lambda local services with no need for an AWS account, yet

```
brew tap aws/tap
brew install aws-sam-cli
```

- [amazon/dynamodb-local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.Docker.html) Docker image to use a local DynamoDB database 
- The AWS lambda function we want to test, has to have its own [SAM Template file](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md) [+info](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-policy-templates.html), named *template.yml* defining the lambda function. See lambda/hello-world folder for a real world example

### Spinning up the local env from scratch

Start the dynamodb container. This will be a *foreground* process so you may want to run it in a second terminal window
```
cd local-env
local-env$ docker-compose up
```

Create the dynamodb table
```
local-env$ ./create-dynamodb-table.sh
```

Expose all API Gateway endpoints to our lambda functions. This will be a *foreground* process so you may want to run it in a second terminal window
```
local-env$ sam local start-api --debug --docker-network hosting-compare
```

Populate the dynamodb table with sample data
```
local-env$ cd ../sample-data/
sample-data$ curl -H "Content-Type: application/json" -XPOST http://127.0.0.1:3000/save/sample_data -d @bluehost.json
```

Browse localhost:PORT TODO


## Hello-World example, working with AWS SAM

- You can run *sam init* and it will create a folder with all AWS SAM files required to start
- You can have a template.yml file in a parent's folder, and use *CodeUri* attribute to reference to the lambda's folder with the code. This way you can have multiple lambda functions started and listening together, but defined in different folders
- There's a limitation (maybe a misunderstood feature) for AWS SAM API Gateway with POST httpd method, which requires a format for the input event in order to be able to process it by the lambda function. That's why in the hello-world folder there are two examples.

**Running the Lambda function with a POST payload locally**

```
# cd /path/to/lambda/folder
cd lambda/hello-world

# Test the lambda function running it directly without exposing a thing
sam local invoke HelloWorldLambda -e payload.json

```

**Expose the lambda function through local API gateway**

```
# cd /path/to/lambda/folder
cd lambda/hello-world

# Start local API Gateway exposing hello-world function via its yaml template. Debug optional.
# IMPORTANT: Each change to the template.yaml requires a sam restart
sam local start-api --debug

# Make a call to the lambda function via its API Gateway exposed port
curl -H "Content-Type: application/json" -XPOST http://127.0.0.1:3000/hello-api-gw -d @payload.json
```

## SAM Template resources

https://docs.aws.amazon.com/es_es/serverless-application-model/latest/developerguide/what-is-sam.html
https://github.com/awslabs/aws-sam-cli/issues/996
https://medium.com/better-programming/how-to-deploy-a-local-serverless-application-with-aws-sam-b7b314c3048c
https://github.com/lvthillo/aws-lambda-sam-demo
