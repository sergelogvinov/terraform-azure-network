
resource "azurerm_network_security_group" "common" {
  for_each            = { for idx, name in var.regions : name => idx }
  location            = each.key
  name                = "${var.network_name}-common-${each.key}"
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Kubernetes-tcp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3000 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["10250", "50000"]
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-tcp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = length(split(".", security_rule.value)) > 1 ? [security_rule.value] : flatten([var.allowlist_datacenters, security_rule.value])
      destination_port_ranges    = ["4240"]
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-udp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3150 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["8472"]
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-icmp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3190 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = "*"
      source_address_prefixes    = length(split(".", security_rule.value)) > 1 ? [security_rule.value] : flatten([var.allowlist_datacenters, security_rule.value])
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  }

  tags = merge(var.tags, { type = "infra" })
}

### Controlplane

resource "azurerm_network_security_group" "controlplane" {
  for_each            = { for idx, name in var.regions : name => idx }
  location            = each.key
  name                = "${var.network_name}-controlplane-${each.key}"
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = {
      "4" : [for ip in var.network_cidr : ip if length(split(".", ip)) > 1],
      "6" : [for ip in var.network_cidr : ip if length(split(":", ip)) > 1],
    }
    content {
      name                       = "Kubernetes-tcp-v${security_rule.key}"
      priority                   = 1570 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = security_rule.value
      destination_port_ranges    = ["6443", "2379-2380", "10250", "50000-50001"]
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-tcp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = length(split(".", security_rule.value)) > 1 ? [security_rule.value] : flatten([var.allowlist_datacenters, security_rule.value])
      destination_port_ranges    = ["4240"]
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-udp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3150 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["8472"]
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-icmp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3190 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = "*"
      source_address_prefixes    = length(split(".", security_rule.value)) > 1 ? [security_rule.value] : flatten([var.allowlist_datacenters, security_rule.value])
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = sort(concat(var.allowlist_admins, var.allowlist_datacenters))
    content {
      name                       = "Datacenters-${security_rule.key}"
      priority                   = 3500 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["6443", "50000-50001"]
      destination_address_prefix = "*"
    }
  }

  tags = merge(var.tags, { type = "infra" })
}

### Web

resource "azurerm_network_security_group" "web" {
  for_each            = { for idx, name in var.regions : name => idx }
  location            = each.key
  name                = "${var.network_name}-web-${each.key}"
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Kubernetes-tcp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3000 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["10250", "50000"]
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-tcp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = length(split(".", security_rule.value)) > 1 ? [security_rule.value] : flatten([var.allowlist_datacenters, security_rule.value])
      destination_port_ranges    = ["4240"]
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-udp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3150 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["8472"]
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Cilium-icmp-v${length(split(".", security_rule.value)) > 1 ? "4" : "6"}"
      priority                   = 3190 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = "*"
      source_address_prefixes    = length(split(".", security_rule.value)) > 1 ? [security_rule.value] : flatten([var.allowlist_datacenters, security_rule.value])
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = sort(concat(var.allowlist_admins, var.allowlist_web))
    content {
      name                       = "WhitelistAdmin-${security_rule.key}"
      priority                   = 3500 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["80", "443"]
      destination_address_prefix = "*"
    }
  }

  tags = merge(var.tags, { type = "infra" })
}

### Peering

resource "azurerm_network_security_group" "router" {
  for_each            = { for idx, name in var.regions : name => idx }
  location            = each.key
  name                = "${var.network_name}-router-${each.key}"
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = var.allowlist_admins
    content {
      name                       = "Icmp-${security_rule.key}"
      priority                   = 1000 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.allowlist_admins
    content {
      name                       = "Admin-${security_rule.key}"
      priority                   = 1500 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_ranges    = ["22"]
      destination_address_prefix = "*"
    }
  }

  security_rule {
    name                       = "Wireguard"
    priority                   = 1600
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_ranges    = ["30443"]
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Peering-${security_rule.key}"
      priority                   = 1700 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_range     = "*"
      destination_address_prefix = security_rule.value
    }
  }
  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Peering-external-${security_rule.key}"
      priority                   = 1700 + security_rule.key
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_range     = "*"
      destination_address_prefix = security_rule.value
    }
  }

  dynamic "security_rule" {
    for_each = var.network_cidr
    content {
      name                       = "Nat-${security_rule.key}"
      priority                   = 1800 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  }

  tags = merge(var.tags, { type = "infra" })
}
