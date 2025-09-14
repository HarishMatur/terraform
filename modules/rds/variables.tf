variable "engine" {
    type = string
    description = "The database engine to use"
    default = "postgres"
}

variable "engine_version" {
    type = string
    description = "The version of the database engine"
    default = "13.4"
}

variable "master_username" {
    type = string
    description = "The master username for the database"
    default = "admin"
}

variable "instance_class" {
    type = string
    description = "The instance type of the RDS instance"
    default = "db.t3.medium"
}

variable "allocated_storage" {
    type = number
    description = "The allocated storage in GB"
}

variable "multi_az" {
    type = bool
    description = "specifies if the RDS instance is multi-AZ"
    default = false
}

variable "publicly_accessible" {
    type = bool
    description = "specifies if the RDS instance is publicly accessible"
    default = false
}

variable "db_name" {
    type = string
    description = "The name of the database to create"
    default ="mydatabase"
}

variable "skip_final_snapshot" {
    type = bool
    description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
    default = true
}

variable "storage_encrypted" {
    type = bool
    description = "Specifies whether the DB instance is encrypted"
    default = true
}

