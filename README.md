# Terraform module for Azure network infrastructure

## Overview

## Usage Example

```hcl
module "network" {
  source = "github.com/sergelogvinov/terraform-azure-network"

  subscription   = var.subscription_id
  resource_group = var.resource_group
  regions        = var.regions

  network_name  = "production"
  network_cidr  = ["172.17.0.0/16", "fd60:172:17::/48"]
  network_shift = 4

  allowlist_datacenters = ["2600:1900::/28"]
  allowlist_admins      = ["1.2.3.4/32"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_group.common](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_private_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route_table.controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_route_table.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.databases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.services](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.shared](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_route_table_association.controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowlist_admins"></a> [allowlist\_admins](#input\_allowlist\_admins) | Allowlist for administrators | `list` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowlist_datacenters"></a> [allowlist\_datacenters](#input\_allowlist\_datacenters) | Allowlist for datacenters subnets | `list` | `[]` | no |
| <a name="input_allowlist_web"></a> [allowlist\_web](#input\_allowlist\_web) | Cloudflare subnets | `list` | <pre>[<br/>  "173.245.48.0/20",<br/>  "103.21.244.0/22",<br/>  "103.22.200.0/22",<br/>  "103.31.4.0/22",<br/>  "141.101.64.0/18",<br/>  "108.162.192.0/18",<br/>  "190.93.240.0/20",<br/>  "188.114.96.0/20",<br/>  "197.234.240.0/22",<br/>  "198.41.128.0/17",<br/>  "162.158.0.0/15",<br/>  "104.16.0.0/13",<br/>  "104.24.0.0/14",<br/>  "172.64.0.0/13",<br/>  "131.0.72.0/22"<br/>]</pre> | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | n/a | `map(any)` | <pre>{<br/>  "all": {<br/>    "network_dns_enable": false<br/>  },<br/>  "uksouth": {<br/>    "network_nat_enable": false,<br/>    "network_peer_enable": false,<br/>    "network_peer_sku": "Standard",<br/>    "network_peer_type": "d2-2"<br/>  }<br/>}</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The cluster dns domain name | `string` | `""` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Local subnet rfc1918 | `list(string)` | <pre>[<br/>  "172.16.0.0/16",<br/>  "fd60:172:16::/48"<br/>]</pre> | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the network | `string` | `"production"` | no |
| <a name="input_network_peering"></a> [network\_peering](#input\_network\_peering) | n/a | `map(any)` | `{}` | no |
| <a name="input_network_shift"></a> [network\_shift](#input\_network\_shift) | Network number shift | `number` | `4` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | The list of regions | `list(string)` | <pre>[<br/>  "uksouth"<br/>]</pre> | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The existing resource group | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The ssh public key: ssh-keygen -t ed25519 -f ~/.ssh/terraform -C 'terraform' | `string` | `""` | no |
| <a name="input_subscription"></a> [subscription](#input\_subscription) | The subscription id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set on resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_controlplane"></a> [network\_controlplane](#output\_network\_controlplane) | The controlplane network |
| <a name="output_network_nat"></a> [network\_nat](#output\_network\_nat) | The nat ips |
| <a name="output_network_private"></a> [network\_private](#output\_network\_private) | The private network |
| <a name="output_network_public"></a> [network\_public](#output\_network\_public) | The public network |
| <a name="output_networks"></a> [networks](#output\_networks) | Regional networks |
| <a name="output_regions"></a> [regions](#output\_regions) | Azure regions |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | Azure resource group |
| <a name="output_secgroups"></a> [secgroups](#output\_secgroups) | List of secgroups |
| <a name="output_subscription"></a> [subscription](#output\_subscription) | Azure subscription ID |
<!-- END_TF_DOCS -->