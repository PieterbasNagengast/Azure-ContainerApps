param location string = resourceGroup().location

// virtual network parameters
param vnetName string = 'aca-vnet'
param vnetAddressPrefix string = '172.16.1.0/24'
param vnetSubnet1Name string = 'subnet1'
param vnetSubnet1Prefix string = cidrSubnet(vnetAddressPrefix, 26, 0)

// Azure Conrtainer App Environment parameters
param acaEnvName string = 'aca-env'

// deploy virtual netowrk
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: vnetSubnet1Name
        properties: {
          addressPrefix: vnetSubnet1Prefix
          delegations: [
            {
              name: 'Microsoft.App/environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
  }
}

// deploy azure container app environment
resource acaEnv 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: acaEnvName
  location: location
  properties: {
    vnetConfiguration: {
      internal: true
      infrastructureSubnetId: vnet.properties.subnets[0].id
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

output vnetId string = vnet.id
output acaEnvId string = acaEnv.id
