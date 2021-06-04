# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet_cicd" {
    name                = "${var.prefix}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet_cicd" {
    name                 = "${var.prefix}-subnet"
    resource_group_name  = var.rg.name
    virtual_network_name = azurerm_virtual_network.vnet_cicd.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create Public HTTP access
resource "azurerm_public_ip" "public_ip_cicd" {
  name                = "${var.prefix}-publicip"
  resource_group_name = var.rg.name
  location            = var.location
  allocation_method   = "Static"
}

# Create Network Security Group and rule
# Network Security Groups control the flow of network traffic in and out of your VM.
resource "azurerm_network_security_group" "nsg_cicd" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic_cicd" {
    name                      = "${var.prefix}-nic"
    location                  = var.location
    resource_group_name       = var.rg.name

    ip_configuration {
        name                          = "${var.prefix}-nic_conf"
        subnet_id                     = azurerm_subnet.subnet_cicd.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip_cicd.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_security_cicd" {
    network_interface_id      = azurerm_network_interface.nic_cicd.id
    network_security_group_id = azurerm_network_security_group.nsg_cicd.id
}

# SSH key generated for accessing VM
resource "tls_private_key" "ssh_cicd" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm_cicd" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = var.rg.name
  network_interface_ids = [azurerm_network_interface.nic_cicd.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-mycomputer"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = "${chomp(tls_private_key.ssh_cicd.public_key_openssh)}" #this openssh connection key will help to connect with Ansible
    }
  }

  connection {
      type        = "ssh"
      user        = "${var.admin_username}" #or root?
      private_key = "${chomp(tls_private_key.ssh_cicd.private_key_pem)}"
      host        = "${azurerm_public_ip.public_ip_cicd.ip_address}"
  }

  provisioner "file" {
    source      = "/team5-resources/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {

    inline = [
      #"sudo su",
      "echo Started to install packages...",
      "sudo apt update",
      "sudo apt install software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible",
      "sudo ansible --version",
      "sudo apt-get install -y openjdk-8-jdk",
      "echo Package installation finished.",
    ]
  }
}

# data source
# Use this data source to access information about an existing Public IP Address.
data "azurerm_public_ip" "public_ip_cicd" {
  name                = azurerm_public_ip.public_ip_cicd.name
  resource_group_name = azurerm_virtual_machine.vm_cicd.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm_cicd]
}