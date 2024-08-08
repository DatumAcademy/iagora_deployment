param virtualMachines_iagora_name string = 'iagora'
param publicIPAddresses_iagora_ip_name string = 'iagora-ip'
param virtualNetworks_iagora_vnet_name string = 'iagora-vnet'
param networkInterfaces_iagora731_z1_name string = 'iagora731_z1'
param networkSecurityGroups_iagora_nsg_name string = 'iagora-nsg'
param sshPublicKey string 
param vmSize string = 'Standard_B2s' 

//NSG ressourc
resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: networkSecurityGroups_iagora_nsg_name
  location: 'francecentral'
  properties: {
    securityRules: [
      {
        name: 'SSH'
        
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'HTTP'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 320
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'HTTPS'
       // id: networkSecurityGroups_iagora_nsg_name_HTTPS.id
        //type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 340
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}


// PUBLIC IP ADDRESS RESSOURCE

resource publicIPAddresses_iagora_ip_name_resource 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIPAddresses_iagora_ip_name
  location: 'francecentral'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
  ]
  properties: {
    ipAddress: '4.233.216.162'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

// VIRTUAL NETWORK RESSOURCE

resource virtualNetworks_iagora_vnet_name_resource 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: virtualNetworks_iagora_vnet_name
  location: 'francecentral'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        //id: virtualNetworks_iagora_vnet_name_default.id
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        //type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

// VIRTUAL MACHINE RESSOURCE

resource virtualMachines_iagora_name_resource 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachines_iagora_name
  location: 'francecentral'
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_iagora_name}_OsDisk_1_bcb7e14b83d24fc7a077197bdf465401'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          /*id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_iagora_name}_OsDisk_1_bcb7e14b83d24fc7a077197bdf465401'
          )*/
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_iagora_name
      adminUsername: virtualMachines_iagora_name
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${virtualMachines_iagora_name}/.ssh/authorized_keys'
              keyData: sshPublicKey 
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
            bypassPlatformSafetyChecksOnUserSchedule: false
          }
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      //requireGuestProvisionSignal: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_iagora731_z1_name_resource.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

//subnet ressourc

resource virtualNetworks_iagora_vnet_name_default 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  name: 'default'
  parent:virtualNetworks_iagora_vnet_name_resource
  properties: {
    addressPrefix: '10.0.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  
}

//interface ressour

resource networkInterfaces_iagora731_z1_name_resource 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: networkInterfaces_iagora731_z1_name
  location: 'francecentral'
  //kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        //id: '${networkInterfaces_iagora731_z1_name_resource.id}/ipConfigurations/ipconfig1'
        //type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_iagora_ip_name_resource.id
            properties: {
              deleteOption: 'Detach'
            }
          }
          subnet: {
            id: virtualNetworks_iagora_vnet_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroups_iagora_nsg_name_resource.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}
