
#Build Puppet 
module "Puppet" {
  source = "../../modules/vsphere_linux"
  servers = 1
  
  # hostname eg dev-puppet1-1
  names = "${var.environment}-puppet${var.site}-1"
  
  
  #IPs for instancees
  ip_addresses    = "${lookup("ip_addresses_puppet", "${var.environment}_site${var.site}")}"
  ip_gateways     = "${lookup("ip_gateways_puppet",  "${var.environment}_site${var.site}")}" 

  
  vsphere_user     = "${var.vsphere_user}"
  vsphere_password = "${var.vsphere_password}"
  vsphere_server   = "${lookup("vsphere_server", "${var.environment}_site${var.site}")}"
  

  app          = "${var.app}"
  site         = "${var.site}"
  environment  = "${var.environment}"
  
  dns_domain   = "${lookup("dns_domain", "${var.environment}")}"
  dns_servers  = "${lookup("dns_servers", "${var.environment}_site${var.site}")}"
  dns_suffixes = "${lookup("dns_suffixes", "${var.environment}_site${var.site}")}"

  
  template_label    = "${var.template.label}"
  template_linked   = "${var.template.linked}"
  template_snapshot = "${var.template.snapshot}"
  disk_datastore    = "${var.disk.datastore}"

  network_interface_label = "${lookup("network_interface_label", "${var.environment}_site${var.site}")}"
  
  # SSH user to connect to new server
  connection_username = "${var.connection.username}"
  connection_password = "${var.connection.password}"
  
  puppetmaster = "${lookup("puppetmasters", "${var.environment}_site${var.site}")}"
}



# ip address are comma separated 
variable "ip_addresses_puppet" {
  default = {
    "dev2_site1"  = "10.0."
    "dev2_site2"  = "10.0."
    "test2_site1" = "10.0."
    "test2_site2" = "10.0."
  }
}
# ip address are comma separated 
variable "ip_gateways_puppet" {
  default = {
    "dev2_site1"  = "10.0."
    "dev2_site2"  = "10.0."
    "test2_site1" = "10.0."
    "test2_site2" = "10.0."
  }
}
