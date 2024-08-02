using 'template.bicep' /*TODO: Provide a path to a bicep template*/

param virtualMachines_iagora_name = 'iagora'

param publicIPAddresses_iagora_ip_name = 'iagora-ip'

param virtualNetworks_iagora_vnet_name = 'iagora-vnet'

param networkInterfaces_iagora731_z1_name = 'iagora731_z1'

param networkSecurityGroups_iagora_nsg_name = 'iagora-nsg'

param sshPublicKey = 'ssh-rsa AAAAB3...your-public-key... user@domain'

param vmSize  = 'Standard_B2s'

