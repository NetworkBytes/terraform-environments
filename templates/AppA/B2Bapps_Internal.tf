
#Build B2BApps Internal servers
module "B2BAppsInternal" {
  source = "../../modules/vsphere_linux"
  servers = 1
  
  # hostname eg dev2-b2bappsi1-1
  names = "${var.environment}-b2bappsi${var.site}-1,${var.environment}-b2bappsi${var.site}-2"
  
  
  #IPs for instancees
  #TODO Tokenize
  ip_addresses    = "${lookup("ip_addresses_B2BAppsInternal", "${var.environment}_site${var.site}")}"
  ip_gateways     = "${lookup("ip_gateways_B2BAppsInternal", "${var.environment}_site${var.site}")}" 

  
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
variable "ip_addresses_B2BAppsInternal" {
  default = {
    "dev2_site1"  = "10.0.x,10.0.x"
    "dev2_site2"  = "10.0.x,10.0.x"
    "test2_site1" = "10.0.x,10.0.x"
    "test2_site2" = "10.0.x,10.0.x"
  }
}
# ip address are comma separated 
variable "ip_gateways_B2BAppsInternal" {
  default = {
    "dev2_site1"  = "10.0.x,10.0.x"
    "dev2_site2"  = "10.0.x,10.0.x"
    "test2_site1" = "10.0.x,10.0.x"
    "test2_site2" = "10.0.x,10.0.x"
  }
}
