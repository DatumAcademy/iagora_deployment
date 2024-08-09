using 'template.bicep' 
/* This template describe all informations about param we used for our vm deployment */

//VM name//
param virtualMachines_iagora_name = 'iagora'
//IP public address name//
param publicIPAddresses_iagora_ip_name = 'iagora-ip'
//virtual network  name//
param virtualNetworks_iagora_vnet_name = 'iagora-vnet'
//network interface  name//
param networkInterfaces_iagora731_z1_name = 'iagora731_z1'
//network security group  name//
param networkSecurityGroups_iagora_nsg_name = 'iagora-nsg'
//SSH public key for VM access//
param sshPublicKey = 'ssh-rsa AAAAB3...your-public-key... user@domain'
//VM size //
param vmSize  = 'Standard_B2s'

