
output "subscription" {
  description = "Azure subscription ID"
  value       = var.subscription
}

output "regions" {
  description = "Azure regions"
  value       = var.regions
}

output "resource_group" {
  description = "Azure resource group"
  value       = var.resource_group
}

output "networks" {
  description = "Regional networks"
  value = merge({ for idx, zone in var.regions : zone => {
    cidr_v4  = local.network_subnet_v4[zone]
    cidr_v6  = local.network_subnet_v6[zone]
    peer_v4  = try(azurerm_public_ip.router_v4[zone].ip_address, "")
    peer_v6  = try(azurerm_public_ip.router_v6[zone].ip_address, "")
    peer_mtu = 1420
    } },
    {
      "ALL" : {
        cidr_v4    = local.network_cidr_v4
        cidr_v6    = local.network_cidr_v6
        network_v4 = one([for ip in var.network_cidr : ip if length(split(".", ip)) > 1])
        network_v6 = one([for ip in var.network_cidr : ip if length(split(":", ip)) > 1])
        dns        = try(azurerm_private_dns_zone.main[0].name, "")
      }
  })
}

output "network_nat" {
  description = "The nat ips"
  value = { for idx, zone in var.regions : zone => {
    ip_v4 = try(azurerm_public_ip.nat[zone].ip_address, "")
  } if lookup(try(var.capabilities[zone], {}), "network_nat_enable", false) }
}

output "network_controlplane" {
  description = "The controlplane network"
  value = { for region, subnet in azurerm_subnet.controlplane : region => {
    network_id = azurerm_virtual_network.main[region].id
    subnet_id  = subnet.id
    cidr_v4    = one([for ip in subnet.address_prefixes : ip if length(split(".", ip)) > 1])
    cidr_v6    = one([for ip in subnet.address_prefixes : ip if length(split(":", ip)) > 1])
  } }
}

output "network_public" {
  description = "The public network"
  value = { for region, subnet in azurerm_subnet.public : region => {
    network_id = azurerm_virtual_network.main[region].id
    subnet_id  = subnet.id
    cidr_v4    = one([for ip in subnet.address_prefixes : ip if length(split(".", ip)) > 1])
    cidr_v6    = one([for ip in subnet.address_prefixes : ip if length(split(":", ip)) > 1])
    sku        = lookup(try(var.capabilities[region], {}), "network_peer_sku", "Standard")
  } }
}

output "network_private" {
  description = "The private network"
  value = { for region, subnet in azurerm_subnet.private : region => {
    network_id = azurerm_virtual_network.main[region].id
    subnet_id  = subnet.id
    cidr_v4    = one([for ip in subnet.address_prefixes : ip if length(split(".", ip)) > 1])
    cidr_v6    = one([for ip in subnet.address_prefixes : ip if length(split(":", ip)) > 1])
    sku        = lookup(try(var.capabilities[region], {}), "network_peer_sku", "Standard")
  } }
}

output "secgroups" {
  description = "List of secgroups"
  value = { for idx, zone in var.regions : zone => {
    common       = azurerm_network_security_group.common[zone].id
    controlplane = azurerm_network_security_group.controlplane[zone].id
    web          = azurerm_network_security_group.web[zone].id
  } }
}
