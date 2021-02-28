# hosting-compare (ops)

## Introduction

This terraform folder contains most of the necessary resources to host the project.

## Platform resources

The following resources have been created, and most of them are managed by terraform defined within this repo folder.

1- **VPC**: the first approach was to create a new VPC with [intra subnets](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#private-versus-intra-subnets) only. However, this added a problem, as the EC2 management instance coudln't be accessed, not even via SSM.
So the VPC code is now defining two private subnets (we will need at least two for the database subnet group parameter) within default's VPC, with no internet access (so no NAT gateway) where to store our database.

2- **Route53 Hosted Zone**: Hosted Zone has been automatically generated when purchasing the domain with AWS, so this was not managed by terraform.

3- **S3**: the public bucket to host the static code. This includes the secondary bucket for www redirect, the two CloudFront distributions to use HTTPS and the DNS records pointing to CloudFront's distributions.

NOTE: At this point, we may need to fix the DNS record Alias as it may be wrongly linked to the CloudFront distributions
NOTE: Also an SSL Certificate for both domains should be manually created via ACM before creating the CloudFront distributions

4- **RDS**: the relational database, hosted in the default VPC's private subnets.

5- **Management EC2 instance**: this is not strictily necessary, as it is not part of the final solution, but it becames pretty handy to have an instance we can use to connect to our database to perform admin operations like:

```
# Dump local development database to use the management EC2 instance to populate RDS
$ docker exec mariadb sh -c 'mysqldump --databases DATABASE -u USER -pPASSWORD' > DATABASE.dump
```


Deploy the lambda function
Docu: https://docs.aws.amazon.com/lambda/latest/dg/python-package.html

## Static website operations

To upload the static web files from scratch we can use aws-cli
```
$ cd www
www$ aws s3 cp . s3://quehosting.es/ --recursive
```

We can also use aws-cli to update files (including deleted ones in origin)
```
$ cd www
www$ aws s3 sync . s3://quehosting.es/ --delete
```
