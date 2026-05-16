
variable "subscription" {
  description = "The subscription id"
  type        = string
}

variable "resource_group" {
  description = "The existing resource group"
  type        = string
}

variable "regions" {
  description = "The list of regions"
  type        = list(string)
  default     = ["uksouth"]
}

variable "domain" {
  description = "The cluster dns domain name"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "The name of the network"
  type        = string
  default     = "production"
}

variable "network_cidr" {
  description = "Local subnet rfc1918"
  type        = list(string)
  default     = ["172.16.0.0/16", "fd60:172:16::/48"]

  validation {
    condition     = length(var.network_cidr) == 2
    error_message = "The network_cidr is a list of IPv4/IPv6 cidr."
  }
}

variable "network_shift" {
  description = "Network number shift"
  type        = number
  default     = 4
}

variable "network_peering" {
  type = map(any)
  default = {
    # "uksouth" = {
    #   "peer-1" = {
    #     ip    = ["1.2.3.4"]
    #     cidrs = ["172.16.0.0/22"]
    #     # BGP parameters for the dynamic peering
    #     asn      = 64512
    #     p2p      = ["169.254.131.96/31", "fd00:169:254:131::/127"]
    #     p2p_side = 0
    #   }
    # }
  }
}

# curl https://www.cloudflare.com/ips-v4 2>/dev/null | awk '{ print "\""$1"\"," }'
variable "allowlist_web" {
  description = "Cloudflare subnets"
  default = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
  ]
}

variable "allowlist_datacenters" {
  description = "Allowlist for datacenters subnets"
  default     = []
}

variable "allowlist_admins" {
  description = "Allowlist for administrators"
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to set on resources"
  type        = map(string)
  default     = {}
}

variable "capabilities" {
  type = map(any)
  default = {
    "all" = {
      network_dns_enable = false
    },
    "uksouth" = {
      network_nat_enable  = false
      network_peer_enable = false
      network_peer_type   = "Standard_B1s"
      network_peer_sku    = "Standard"
    },
  }
}

variable "ssh_key" {
  description = "The ssh public key: ssh-keygen -t ed25519 -f ~/.ssh/terraform -C 'terraform'"
  type        = string
  default     = ""
}
