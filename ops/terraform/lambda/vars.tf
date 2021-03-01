#
# Vars defined to be requested as input values when applying terraform
#

variable "db_host" {
  description = "The RDS endpoint"
}

variable "db_user" {
  description = "The RDS user"
}

variable "db_pass" {
  description = "The RDS password"
}

variable "db_name" {
  description = "The database name to connect to"
}
