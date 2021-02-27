# hosting-compare (ops)

## Introduction

This terraform folder contains most of the necessary resources to host the project.

## Platform resources

1- VPC: the private VPC to host the database and the lambda functions.
2- Route53 Hosted Zone: it has been automatically generated when purchasing the domain with AWS, so this was not managed by terraform.
3- S3: the public bucket to host the static code. This includes the secondary bucket for www redirect,the cloudfront distributions to use HTTPS and the DNS records pointing to cloudfront's distributions
NOTE: At this point, we may need to fix the DNS record Alias as it may be wrongly linked
NOTE: Also an SSL Certificate for both domains should be manually created via ACM before creating the CloudFront distributions

## Static website operations

To upload the static web files from scratch we can use aws-cli
```
$ cd www
www$ aws s3 cp . s3://quehosting.es/ --recursive
```

We can also use aws-cli to update files
```
$ cd www
www$ aws s3 sync . s3://quehosting.es/
```
