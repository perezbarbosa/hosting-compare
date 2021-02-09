#!/usr/bin/env bash

MYSQL_DATABASE=quehosting
MYSQL_ROOT_PASSWORD=quehosting.es

# Hosting Plans table
create_hosting_table="CREATE TABLE IF NOT EXISTS hosting_plan(
id INT AUTO_INCREMENT PRIMARY KEY,
currency VARCHAR(3),
database_number INT,
database_size INT,
disk_size INT,
disk_type VARCHAR(255),
domain_included VARCHAR(255),
domain_subdomain INT,
domains_parked INT,
hosting_plan VARCHAR(255) NOT NULL,
hosting_type VARCHAR(255) NOT NULL,
partition_key VARCHAR(255) NOT NULL,
payment_month_min DECIMAL(6,2) NOT NULL,
provider VARCHAR(255) NOT NULL,
ssl_certificate VARCHAR(255),
web_number INT,
INDEX (partition_key),
INDEX (payment_month_min)
) ENGINE=INNODB;"

# Support types table
create_support_table="CREATE TABLE IF NOT EXISTS support(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL
) ENGINE=INNODB;"

# HostingPlans - SupportTypes relationship
create_hosting_support_table="CREATE TABLE IF NOT EXISTS hosting_support(
hosting_plan_id INT,
support_id INT,
FOREIGN KEY (hosting_plan_id)
    REFERENCES hosting_plan (id)
    ON DELETE CASCADE,
FOREIGN KEY (support_id)
    REFERENCES support (id)
    ON DELETE CASCADE
) ENGINE=INNODB;"

docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_hosting_table" $MYSQL_DATABASE
docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_support_table" $MYSQL_DATABASE
docker exec mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$create_hosting_support_table" $MYSQL_DATABASE