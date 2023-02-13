
# To use SSH to connect to the virtual machine, do the following steps:

## run terraform output to get the SSH private key and save it to a file.

terraform output -raw tls_private_key > id_rsa

## Run terraform output to get the virtual machine public IP address.
terraform output public_ip_address

## Use SSH to connect to the virtual machine.
ssh -i id_rsa azureuser@<public_ip_address>

## To see a list of the most commonly used images, use the az vm image list command.
az vm image list --output table

## To see a list of VM sizes available in a particular region, use the az vm list-sizes command.
az vm list-sizes --location southafricanorth --output table