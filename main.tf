variable "subscriptionId" {}
variable "clientId" {}
variable "clientSecret" {}
variable "tenantId" {}
variable "region" {}
variable "hradwareType" {}
variable "vmname" {}
variable "rgName" {}
variable "network" {}
variable "subnet" {}

provider "azurerm" {
  subscription_id = "${var.subscriptionId}"
  client_id       = "${var.clientId}"
  client_secret   = "${var.clientSecret}"
  tenant_id       = "${var.tenantId}"
}

data "azurerm_resource_group" "main" {
  name     = "${var.rgName}"
}

data "azurerm_virtual_network" "main" {
  name                = "${var.network}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
}

data "azurerm_subnet" "internal" {
  name                 = "${var.subnet}"
  resource_group_name  = "${data.azurerm_resource_group.main.name}"
  virtual_network_name = "${data.azurerm_virtual_network.main.name}"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vmname}-nic"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.vmname}"
  location              = "${data.azurerm_resource_group.main.location}"
  resource_group_name   = "${data.azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "${var.hradwareType}"
          
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true
         
        
  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true
      
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  } 

storage_os_disk {
    name              = "myosdisk1" 
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


