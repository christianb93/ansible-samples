######################################################################
# Variables
######################################################################

# The DigitalOcean oauth token. We will set this with the
#  -var="do_token=..." command line option
variable "do_token" {}

# The SSH key that we will use to access our machines
variable "ssh_key_name" {
  type = string
  default = "do-default-key"
}

# The number of machines to provide
variable "machine_count" {
  type = number
  default = 1
}

# The size
variable "size_slug" {
  type = string
  default = "s-1vcpu-1gb"
}

# The OS image
variable "os_slug" {
  type = string
  default = "ubuntu-18-04-x64"
}

# The region
variable "region" {
  type = string
  default = "fra1"
}
