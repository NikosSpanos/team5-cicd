variable "location" {
	description = "Resource group location"
}

variable "prefix" {
  description = "Resource group prefix (i.e development/ production)"
}

variable "admin_username" {
  description = "username for vm instance"
  default = "codehubTeam5"
}

variable rg {
	description = "Resource Group Object"
}