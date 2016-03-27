variable "servers" {
    default     = "3"
    description = "The number of Consul servers to launch"
}

variable "tag_name" {
    default     = "consul"
    description = "Name tag for the servers"
}