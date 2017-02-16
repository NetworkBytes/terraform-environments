variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {
  default = {
    "dev2_site1" = "vcn"
    "dev2_site2" = "vcn"
    "test2_site1" = "vcn"
    "test2_site2" = "vcn"
  }
}

variable "environment" {}
variable "site" {}
variable "app" {}

variable "time_zone" { default = "Australia/Sydney"}

variable "template" {
  default = {
    "label"    = "Templates/Redhat-7.2-x86_64_Template_20160214.2253"
    "linked"   = true
    "snapshot" = "base"
  }
}

variable disk {
  default = {
    "datastore" = "NFS"
  }
}


variable "network_interface_label" {
  default = {
    "dev2_site1"  = "DEVNET"
    "dev2_site2"  = "DEVNEW"
    "test2_site1" = "TESTNET"
    "test2_site2" = "TESTNET"
  }
}

variable "dns_servers" {
  default = {
    "dev2_site1"  = "10.0.x,10.0.x"
    "dev2_site2"  = "10.0.x,10.0.x"
    "test2_site1" = "10.0.x,10.0.x"
    "test2_site2" = "10.0.x,10.0.x"
  }
}

variable "dns_suffixes" {
  default = {
    "dev2_site1"  = "dev2,management"
    "dev2_site2"  = "dev2,management"
    "test2_site1" = "test,test2,management"
    "test2_site2" = "test,test2,management"

  }
}

variable "dns_domain" {
  default = {
    "dev" = "dev"
    "dev2" = "dev2"
    "test" = "test"
    "test2" = "test2"
    }
}

# default packer build credentials
variable "connection" {
  default = {
    "username" = "root"
    "password" = ""
  }
}

variable "puppetmasters" {
  default = {
    "dev2_site1"  = "dev-puppet"
    "dev2_site2"  = "dev-puppet"
    "test2_site1" = "dev-puppet"
    "test2_site2" = "dev-puppet"
  }
}