variable "region" {
  description = "default region"
  type        = string
  default     = "ap-south-1"
}

variable "ami" {
  description = "ami of the ec2"
  type        = string
}

variable "instance_type" {
  description = "instance type of ec2"
  type        = string

}
variable "environment" {
  type = string
}

variable "project" {
  type = string
}