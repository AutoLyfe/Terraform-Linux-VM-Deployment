# Use Terraform to create a Linux VM

Terraform module to create a complete Linux environment which include a virtual network, subnet, public IP address and more, according to <a href= 
"https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform">Microsoft Learn</a>


# Usage

I have decided to stray from the example provided in the Microsoft learn documentation and create multiple subnets using the for_each loop 

```terraform
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  resource_group_name  = azurerm_resource_group.Test_RG.name
  virtual_network_name = azurerm_virtual_network.Test_Vnet.name
  name                 = each.value["name"]
  address_prefixes     = each.value["address_prefixes"]
}

resource "azurerm_subnet_network_security_group_association" "Test_SA" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.Test_NSG.id
}
```

# Create Network Security Group
resource "azurerm_network_security_group" "Test_NSG" {
  name                = "${var.Prefix}-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.Test_RG.name
}


# To use SSH to connect to the virtual machine, do the following:

### Run terraform output to get the SSH private key and save it to a file.
 - terraform output -raw tls_private_key > id_rsa

### Run terraform output to get the virtual machine public IP address.
 - terraform output public_ip_address. 
 - If your having trouble seeing the IP after running the output command run **"terraform apply -refresh-only"** to refresh the state file.

### Use SSH to connect to the virtual machine.
 - ssh -i id_rsa azureuser@<public_ip_address>
