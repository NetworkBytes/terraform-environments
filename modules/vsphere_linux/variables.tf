# Input variables - used when calling this module
# must be a string
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "servers" { default = 1 }
variable "names" {}

variable "app" {}
variable "site" {}
variable "environment" {}

variable "time_zone" { default = "Australia/Sydney"}
variable "resource_pool" { default = "3.Bronze" }


# networking
variable "network_interface_label" {}
variable "ip_addresses" {}
variable "ip_gateways" {}
variable "dns_domain" {}
variable "dns_servers" {}
variable "dns_suffixes" {}

# disk
variable "template_label" {}
variable "template_linked" {}
variable "template_snapshot" {}
variable "disk_datastore" {} 

# ssh details
variable connection_username {}
variable connection_password {}

variable "puppetmaster" {}

