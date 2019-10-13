######################################################################
# Global setup
######################################################################
# The DigitalOcean provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# The backend - we use PostgreSQL
terraform {
  backend "pg" {
  }
}


######################################################################
# Outputs
# Note that we need an output for each resource definition below.
# If you add additional resources, you will have to add a new variable
# to the locals block below and add this variable to the concat
# statement that makes up the output inventory
######################################################################

locals {
  web_inventory =  [for s in digitalocean_droplet.web[*] : {
    # the Ansible groups to which we will assign the server
    "groups" : "['web']",
    "name"   : "${s.name}",
    "ip"     : "${s.ipv4_address}"
  } ]
  db_inventory =  [for s in digitalocean_droplet.db[*] : {
    "groups" : "['db']",
    "name"   : "${s.name}",
    "ip"     : "${s.ipv4_address}"
  } ]
}


output "inventory" {
  value = concat(local.web_inventory, local.db_inventory)
}




######################################################################
# Data sources and resources
######################################################################


# A datasource that will give us access to the SSH key ID
data "digitalocean_ssh_key" "ssh_key_data" {
  name = "${var.ssh_key_name}"
}

# We want to droplet that we will later put into a group
# web that will hold our web serves
resource "digitalocean_droplet" "web" {
  image  = var.os_slug
  name   = "web${count.index}"
  region = var.region
  size   = var.size_slug
  ssh_keys = [ data.digitalocean_ssh_key.ssh_key_data.id ]
  tags = ["ManagedByTerraform", "web"]
  count = var.web_machine_count
}

# We also bring up two DB servers. In a real world example,
# we would probably use a different configuration, e.g. with
# a bit more memory
resource "digitalocean_droplet" "db" {
  image  = var.os_slug
  name   = "db${count.index}"
  region = var.region
  size   = var.size_slug
  ssh_keys = [ data.digitalocean_ssh_key.ssh_key_data.id ]
  tags = ["ManagedByTerraform", "web"]
  count = var.db_machine_count
}
