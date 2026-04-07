@description('Location for all resources')
param location string = 'eastus2'

@description('Admin username for the VM')
param adminUsername string = 'cs-server'

@description('SSH public key for authentication')
param sshPublicKey string

@description('VM size')
param vmSize string = 'Standard_B1s'

@description('OS disk size in GB')
param osDiskSizeGB int = 30

var resourcePrefix = 'cs16'
var vmName = '${resourcePrefix}-server'
var nicName = '${resourcePrefix}-nic'
var vnetName = '${resourcePrefix}-vnet'
var subnetName = 'default'
var publicIPv4Name = '${resourcePrefix}-pip-ipv4'
var nsgName = '${resourcePrefix}-nsg'
var storageAccountName = '${resourcePrefix}backups${uniqueString(resourceGroup().id)}'

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'CS16-UDP'
        properties: {
          priority: 1010
          protocol: 'Udp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '27015'
        }
      }
      {
        name: 'CS16-TCP'
        properties: {
          priority: 1020
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '27015'
        }
      }
    ]
  }
}

// Virtual Network (IPv4)
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Public IP (IPv4)
resource publicIPv4 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIPv4Name
  location: location
  sku: {
    name: 'Basic'  // Changed from 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'  // Changed from 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-ipv4'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPv4.id
          }
          primary: true
        }
      }
    ]
  }
}

// Storage Account for backups
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
  }
}

// Blob container for backups
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'server-backups'
}

// Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// VM Extension for initial setup


output vmPublicIPv4 string = publicIPv4.properties.ipAddress
output storageAccountName string = storageAccount.name
output sshCommand string = 'ssh ${adminUsername}@${publicIPv4.properties.ipAddress}'