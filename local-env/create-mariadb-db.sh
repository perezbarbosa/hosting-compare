#!/usr/bin/env bash

MYSQL_DATABASE=quehosting
MYSQL_ROOT_PASSWORD=quehosting.es

# Hosting Plans table
create_hosting_table="CREATE TABLE IF NOT EXISTS hosting_plan(
id INT AUTO_INCREMENT PRIMARY KEY,
Currency VARCHAR(3),
DatabaseNumber INT,
DatabaseSize INT,
DiskSize INT,
DiskType VARCHAR(255),
DomainIncluded VARCHAR(255),
DomainSubdomain INT,
DomainsParked INT,
HostingPlan VARCHAR(255) NOT NULL,
HostingType VARCHAR(255) NOT NULL,
PartitionKey VARCHAR(255) NOT NULL UNIQUE,
PaymentMonthMin DECIMAL(6,2) NOT NULL,
Provider VARCHAR(255) NOT NULL,
SslCertificate VARCHAR(255),
SupportList VARCHAR(1024),
Url VARCHAR(255) NOT NULL,
WebNumber INT,
INDEX (PartitionKey),
INDEX (PaymentMonthMin)
) ENGINE=INNODB;"


docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_hosting_table" $MYSQL_DATABASE