variable "location" {
	type = string
	default = "westeurope"
}

variable "prefix" {
	type = string
	description = "The cicd prefix"
}

variable "tags" {
  type = map
  default = {
    Environment = "CI/CD Pipeline"
    Version = "1"
    Team = "Team 5"
  }
}

variable "admin_username" {
  description = "username for vm instance"
  default = "codehubTeam5"
}

variable "subscription_id"{
    description = "The subscription id"
    default = "3ec335d6-1a42-463b-95e2-4fde3269c94d"
}

variable "client_appId"{
    default = "ae3d9551-4b0a-4381-893e-ca7e44f83198"
}

variable "client_password"{
    default = "CWV-1cnnUVAswO5-GEonM6M5Bawj-LSEaH"
}

variable "tenant_id"{
    default = "b1732512-60e5-48fb-92e8-8d6902ac1349"
}