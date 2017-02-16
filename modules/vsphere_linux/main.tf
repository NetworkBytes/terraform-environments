
# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  allow_unverified_ssl = "true"
}


# Create a vm folder
resource "vsphere_folder" "base" {
  path = "Terraform/${var.environment}/${var.app}"
  datacenter = "DC${var.site}"
}

# create virtual machine
resource "vsphere_virtual_machine" "vsphere_linux" {

  # Count per site
  count = "${var.servers}"

  name   = "${element("${split(",", var.names)}" , count.index)}"
  folder = "${vsphere_folder.base.path}"
  vcpu   = 2
  memory = 4096
  
  
  datacenter = "DC${var.site}"
  cluster = "Cluster${var.site}"
  resource_pool = "${var.resource_pool}"
  gateway = "${element("${split(",", var.ip_gateways)}" , count.index)}"
  
  domain = "${var.dns_domain}" 
  time_zone = "${var.time_zone}"
  
  dns_suffixes = ["${split(",", "${var.dns_suffixes}"  )}"]
  dns_servers = ["${split(",", "${var.dns_servers}"  )}"]
 
  network_interface {
    label = "${var.network_interface_label}"
    ipv4_address = "${element("${split(",", var.ip_addresses)}" , count.index)}"
    ipv4_prefix_length = 24
    adapter_type = "vmxnet3"
  }

  disk {
    template {
      label = "${var.template_label}"
      linked = "${var.template_linked}"
      snapshot = "${var.template_snapshot}"
    }
    
    datastore = "${var.disk_datastore}"
    #size = <int>
    #iops = <int>
  }
  
  #custom_configuration_parameters = {
  #  isolation.tools.copy.disable = "false"
  #  isolation.tools.paste.disable = "false"
  #}

  
  # Generate Puppet certs
  provisioner "local-exec" {
    command = "powershell -command ./scripts/generate_puppet_cert.ps1 -puppetmaster ${var.puppetmaster} -puppetclient ${self.name}.${self.domain}"
  }
 
  # Upload files to new server
  provisioner "file" {
    source = "./Temp/${self.name}.${self.domain}/"
    destination = "/tmp/"
  }
  
  # Run Puppet
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/puppetlabs/puppet/ssl/public_keys",
      "cp -vf /tmp/ssl/certs/* /etc/puppetlabs/puppet/ssl/public_keys/",
      "mkdir -p /etc/puppetlabs/puppet/ssl/private_keys",
      "cp -vf /tmp/ssl/private_keys/* /etc/puppetlabs/puppet/ssl/private_keys/",
      "puppet agent --test"
    ]
  }

  
  connection {
    type     = "ssh"
    user     = "${var.connection_username}"
    password = "${var.connection_password}"
    host     = "${element("${split(",", var.ip_addresses)}" , count.index)}"
    
    #bastion_host     = ""
    #bastion_user     =  ""
    #bastion_password = ""
  }
}
