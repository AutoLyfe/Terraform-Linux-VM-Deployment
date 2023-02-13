
# Create resource group
resource "azurerm_resource_group" "Test_RG" {
  name     = "${var.Prefix}-RG"
  location = var.location
  tags     = var.tags
}


# Create virtual network
resource "azurerm_virtual_network" "Test_Vnet" {
  name                = "${var.Prefix}-Vnet"
  resource_group_name = azurerm_resource_group.Test_RG.name
  address_space       = var.vnet_address_space
  location            = var.location
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  resource_group_name  = azurerm_resource_group.Test_RG.name
  virtual_network_name = azurerm_virtual_network.Test_Vnet.name
  name                 = each.value["name"]
  address_prefixes     = each.value["address_prefixes"]
}


# Create Network Security Group
resource "azurerm_network_security_group" "Test_NSG" {
  name                = "${var.Prefix}-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.Test_RG.name
}


# Create Network Security Group rule
resource "azurerm_network_security_rule" "Test_SR1" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Test_RG.name
  network_security_group_name = azurerm_network_security_group.Test_NSG.name
}


# Connect the network security group to the subnets
resource "azurerm_subnet_network_security_group_association" "Test_SA" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.Test_NSG.id
}


# Create public IPs
resource "azurerm_public_ip" "Test_PIP" {
  name                = "${var.Prefix}-PIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.Test_RG.name
  allocation_method   = "Dynamic"
}


# Create (and display) an SSH key
resource "tls_private_key" "test_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Generate random text for a unique storage account name
resource "random_id" "test_random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.Test_RG.name
  }

  byte_length = 8
}

# Create storage account
resource "azurerm_storage_account" "Test_STG" {
  name                     = "demostg${random_id.test_random_id.hex}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.Test_RG.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Create network interface
resource "azurerm_network_interface" "Test_NIC" {
  name                = "${var.Prefix}-NIC"
  location            = var.location
  resource_group_name = azurerm_resource_group.Test_RG.name

  ip_configuration {
    name                          = "Test-Configuration"
    subnet_id                     = azurerm_subnet.subnet["subnet_1"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Test_PIP.id
  }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "TestVM"
  location              = var.location
  resource_group_name   = azurerm_resource_group.Test_RG.name
  network_interface_ids = [azurerm_network_interface.Test_NIC.id]
  size                  = "Standard_DS1_v2"

  custom_data = filebase64("customdata.tpl") # filebase64 reads the contents of a file at the given path and returns them as a base64-encoded string.

  os_disk {
    name                 = "TestOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "testvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.test_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.Test_STG.primary_blob_endpoint
  }
}
