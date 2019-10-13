# The DigitalOcean provider
provider "digitalocean" {
  token = "${var.do_token}"
}

######################################################################
# Data sources and resources
######################################################################

# A datasource that will give us access to the SSH key ID
data "digitalocean_ssh_key" "ssh_key_data" {
  name = "${var.do_ssh_key_name}"
}

resource "digitalocean_droplet" "droplet" {
  image  = var.os_slug
  name   = "${var.nameRoot}${count.index}"
  region = var.region
  size   = var.size_slug
  ssh_keys = [ data.digitalocean_ssh_key.ssh_key_data.id ]
  tags = ["ManagedByTerraform", "${var.nameRoot}"]
  count = var.machine_count
}
