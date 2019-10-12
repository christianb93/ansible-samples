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
# If you add additional lines, use the existing lines as template
# with the following changes:
# - change the groups parameters, this is a list of the groups to
#   which we will later add the server
# - change the resource name in the variables referenced in the line
######################################################################


output "web" {
  value = formatlist("{ \"groups\" : \"['web']\", \"name\" : \"%s\" , \"ip\" :   \"%s\" }",  digitalocean_droplet.web[*].name, digitalocean_droplet.web[*].ipv4_address)
}

output "db" {
  value = formatlist("{ \"groups\" : \"['db']\", \"name\" : \"%s\" , \"ip\" :   \"%s\" }",  digitalocean_droplet.db[*].name, digitalocean_droplet.db[*].ipv4_address)
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
