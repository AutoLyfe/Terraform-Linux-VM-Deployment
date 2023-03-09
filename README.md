# Use Terraform to create a Linux VM

Terraform project to create a complete Linux environment which includes a virtual network, subnet, public IP address and more, according to <a href= 
"https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform">Microsoft Learn</a>


# Usage

I have decided to stray from the example provided in the Microsoft learn documentation and create multiple subnets using the for_each loop. Note the syntax needed to associate both subnets to the Network Security Group

```terraform
# Create multiple subnet
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
```

# Bootstrap the VM with Docker

I decided to furthur add onto the original deployment by bootstrapping the VM with Docker using the below Bash Script

```bash
#!/bin/bash
sudo apt-get update -y && 
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSl https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker ubuntu
```


# To use SSH to connect to the virtual machine, do the following:

1. Run [terraform output](https://www.terraform.io/cli/commands/output) to get the SSH private key and save it to a file.

    ```console
    terraform output -raw tls_private_key > id_rsa
    ```

1. Run [terraform output](https://www.terraform.io/cli/commands/output) to get the virtual machine public IP address.

    ```console
    terraform output public_ip_address
    ```

1. Use SSH to connect to the virtual machine.

    ```console
    ssh -i id_rsa azureuser@<public_ip_address>
    ```
