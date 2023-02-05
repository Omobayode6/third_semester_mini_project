variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "ubuntu server instance type"
}
variable "key_name" {
  type        = string
  default     = "altschool-holiday-project"
  description = "ubuntu server instance private_key"
}
variable "domain_name" {
  type        = string
  default     = "omobayode.me"
  description = "my domain name"
}