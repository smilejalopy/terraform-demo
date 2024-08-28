variable "root_id" {
  type    = string
  default = "TFW"
}

variable "root_name" {
  type    = string
  default = "TFWorkshop"
}
variable "default_location" {
  type    = string
  default = "australiaeast"
}
variable "resource_group_location" {
   type = string
   default = "australiaeast"
   description = "Location of the Resource Group"
}

variable "prefix" {
  type = string
  default = "tfw"
  description = "Prefix for TF Workshop"
}