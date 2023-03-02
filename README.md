# Use Terraform to create a Linux VM

Terraform module to create a complete Linux environment which include a virtual network, subnet, public IP address and more, according to <a href= 
"https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform">Microsoft Learn</a>


# Usage



# To use SSH to connect to the virtual machine, do the following:

### Run terraform output to get the SSH private key and save it to a file.
 - terraform output -raw tls_private_key > id_rsa

### Run terraform output to get the virtual machine public IP address.
 - terraform output public_ip_address. 
 - If your having trouble seeing the IP after running the output command run **"terraform apply -refresh-only"** to refresh the state file.

### Use SSH to connect to the virtual machine.
 - ssh -i id_rsa azureuser@<public_ip_address>
