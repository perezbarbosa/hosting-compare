# hosting-compare (ops)

## Introduction

This terraform folder contains most of the necessary resources to host the project.

## Platform resources

The following resources have been created, and most of them are managed by terraform defined within this repo folder.

1- **VPC**: the first approach was to create a new VPC with [intra subnets](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#private-versus-intra-subnets) only. However, this added a problem, as the EC2 management instance coudln't be accessed, not even via SSM.
So the VPC code is now defining two private subnets (we will need at least two for the database subnet group parameter) within default's VPC, with no internet access (so no NAT gateway) where to store our database.

NOTE: default VPC's public subnets have been manually tagged as "Tier":"Public" in order for the lambda function to use them.

2- **Route53 Hosted Zone**: Hosted Zone has been automatically generated when purchasing the domain with AWS, so this was not managed by terraform.

3- **S3**: the public bucket to host the static code. This includes the secondary bucket for www redirect, the two CloudFront distributions to use HTTPS and the DNS records pointing to CloudFront's distributions.

NOTE: At this point, we may need to fix the DNS record Alias as it may be wrongly linked to the CloudFront distributions
NOTE: Also an SSL Certificate for both domains should be manually created via ACM before creating the CloudFront distributions

4- **Lambda**: the lambda folder includes the [VPC lambda function](https://aws.amazon.com/blogs/aws/new-access-resources-in-a-vpc-from-your-lambda-functions/), meaning the lambda (placed in public subnets) will have its own security group, which will be used by the RDS to restrict access only to that function. 

5. **API Gateway**: the API Gateway is created at this point, exposing the lambda function to the world. It also grants permissions to the lambda to be invoked by the API Gateway and finally returns a terraform output to facilitate to get the API Gateway invokation endpoint. 

5- **RDS**: the relational database, hosted in the default VPC's private subnets.

6- **EC2**: this is not strictily necessary, as it is not part of the final solution, but it becames pretty handy to have an EC2 instance we can use to connect to our database to perform admin operations like:

```
# Dump local development database to use the management EC2 instance to populate RDS
❯ docker exec mariadb sh -c 'mysqldump --databases DATABASE -u USER -pPASSWORD' > DATABASE.dump
```

### Testing the API Gateway

Once created, we can create a test payload like this:

```
❯ cat /tmp/payload
{
  "HostingType": "Wordpress",
  "MonthlyPrice": "Price99",
  "DomainIncluded": "Todos"
}
```

Then run a curl call against the API Gateway invokation endpoint

```
❯ curl -vX POST https://yg7cplba88.execute-api.eu-west-2.amazonaws.com/dev/search -d @/tmp/payload --header "Content-Type: application/json"
```

### How to generate the lambda zip package

Docu: https://docs.aws.amazon.com/lambda/latest/dg/python-package.html

```
# Create venv to install dependencies
❯ cd /tmp
❯ /usr/bin/python3 -m venv myenv
❯ source myenv/bin/activate
❯ pip install pymysql
❯ deactivate

# Create a zip including dependencies
❯ cd myenv/lib/python3.7/site-packages/
❯ zip -r ~/search.zip . 

# Add the lambda function to the existing zip file
❯ zip -g ~/search.zip search.py
```

## Static website operations

To upload the static web files from scratch we can use aws-cli
```
❯ cd www
www❯ aws s3 cp . s3://quehosting.es/ --recursive
```

We can also use aws-cli to update files (including deleted ones in origin)
```
❯ cd www
www❯ aws s3 sync . s3://quehosting.es/ --delete
```
