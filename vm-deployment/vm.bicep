/*
Virtual machine deployment.
*/

// Parameters for resource names
@description('Prefix for naming Azure resources.')
param namePrefix string = 'iagora'

var virtualMachineName = '${namePrefix}-vm'
var virtualNetworkName = '${namePrefix}-vnet'
var publicIPAddressName = '${namePrefix}-ip'
var networkInterfaceName = '${namePrefix}-nic'
var networkSecurityGroupName = '${namePrefix}-nsg'

@description('The SSH public key to use for authentication.')
param sshPublicKey string

@description('The size of the virtual machine.')
param vmSize string = 'Standard_B2s'

@description('The location where resources are deployed.')
param location string = resourceGroup().location

@description('The private IP address for the virtual machine.')
param privateIPAddress string = '10.0.0.4'

@description('The address prefix for the virtual network.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The address prefix for the subnet.')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Operating system disk size in Gigabytes.')
param diskSizeGB int = 30

@description('List of ports to allow for inbound TCP traffic. Example: [22, 80, 443].')
param allowedTcpPorts array = [22, 80, 443]

@description('Username for the Virtual Machine administrator.')
@maxLength(64)
@minLength(1)
param adminUsername string

@description('Operating system disk Stock Keeping Unit name.')
@allowed([
  'PremiumV2_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param diskSku string = 'Premium_LRS'

@description('The priority of the Virtual Machine.')
@allowed([
  'Regular'
  'Low'
  'Spot'
])
param vmPriority string = 'Regular'

// Networking security group
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [for (port, portIndex) in allowedTcpPorts: {
        name: 'AllowTcp${port}'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '${port}'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          priority: 300 + (portIndex * 20)
          protocol: 'TCP'
        }
      }]
  }
}

// Public IP address
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    // The ddosSettings are set to their defaults to prevent `what-if` command noise.
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

// Virtual network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'// Although `privateEndpointNetworkPolicies=Disabled` is the default value,
          // the `what-if` command outputs noise (wrongly detects change to 'Enabled').
          // See https://github.com/Azure/arm-template-whatif/issues/284.
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

// Virtual machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      computerName: virtualMachineName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: sshPublicKey
              path: '/home/${adminUsername}/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    priority: vmPriority
    storageProfile: {
      imageReference: {
        offer: '0001-com-ubuntu-server-jammy'
        publisher: 'Canonical'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: diskSizeGB
        managedDisk: {
          storageAccountType: diskSku
        }
        name: '${virtualMachineName}_OsDisk_1'
        osType: 'Linux'
      }
    }
  }
}

// Network interface
resource networkInterface 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
    // The disableTcpStateTracking, ddosSettings, is set to its default to prevent `what-if` command noise.
    // See https://github.com/Azure/arm-template-whatif/issues/356
    disableTcpStateTracking: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddress: privateIPAddress
          publicIPAddress: {
            id: publicIPAddress.id
            properties: {
              deleteOption: 'Detach'
            }
          }
          subnet: {
            id: '${virtualNetwork.id}/subnets/default'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

output sshCommand string = 'ssh ${adminUsername}@${publicIPAddress.properties.ipAddress}'
