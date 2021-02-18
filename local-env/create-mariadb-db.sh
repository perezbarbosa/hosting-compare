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
WebNumber INT,
INDEX (PartitionKey),
INDEX (PaymentMonthMin)
) ENGINE=INNODB;"

# Support types table
create_support_table="CREATE TABLE IF NOT EXISTS support(
id INT AUTO_INCREMENT PRIMARY KEY,
Name VARCHAR(255) NOT NULL
) ENGINE=INNODB;"

# HostingPlans - SupportTypes relationship
create_hosting_support_table="CREATE TABLE IF NOT EXISTS hosting_support(
HostingPlanId INT,
SupportId INT,
FOREIGN KEY (HostingPlanId)
    REFERENCES hosting_plan (id)
    ON DELETE CASCADE,
FOREIGN KEY (SupportId)
    REFERENCES support (id)
    ON DELETE CASCADE
) ENGINE=INNODB;"

docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_hosting_table" $MYSQL_DATABASE
docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_support_table" $MYSQL_DATABASE
docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_hosting_support_table" $MYSQL_DATABASE

# Insert Support table
for support in chat email phone ticket
do
    docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "INSERT INTO support (Name) VALUES ('$support')" $MYSQL_DATABASE
done