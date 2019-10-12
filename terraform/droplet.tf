######################################################################
# Global setup
######################################################################
# The DigitalOcean provider
provider "digitalocean" {
  token = "${var.do_token}"
}


######################################################################
# Outputs
######################################################################


# This output holds the IP addresses of the instances that we bring up
output "instance_ip_addr" {
  value = digitalocean_droplet.droplets[*].ipv4_address
}

# this output holds the names
output "instance_names" {
  value = digitalocean_droplet.droplets[*].name
}


######################################################################
# Data sources and resources
######################################################################


# A datasource that will give us access to the SSH key ID
data "digitalocean_ssh_key" "ssh_key_data" {
  name = "${var.ssh_key_name}"
}

# The actual droplets
resource "digitalocean_droplet" "droplets" {
  image  = var.os_slug
  name   = "droplet${count.index}"
  region = var.region
  size   = var.size_slug
  ssh_keys = [ data.digitalocean_ssh_key.ssh_key_data.id ]
  count = var.machine_count
}
