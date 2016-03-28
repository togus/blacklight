variable "servers" {
    default     = "1"
    description = "The number of Consul servers to launch"
}

variable "mysql_servers" {
    default     = "2"
    description = "The number of Mysql servers to launch"
}

variable "tag_name" {
    default     = "consul"
    description = "Name tag for the servers"
}

variable "tag_name_mysql" {
    default     = "mysql"
    description = "Name tag for the servers"
}