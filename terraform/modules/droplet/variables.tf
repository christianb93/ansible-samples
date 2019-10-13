###################################################
# First, there is a couple of variables that do
# not have a default and that need to be provided
# when invoking the module
###################################################

# The DigitalOcean token
variable "do_token" {
  type = string
}

# The ansible groups in which we will place the machines
# This is only needed for assembling the output which
# is an inventory list
variable "ansibleGroups" {
  type = string
}

# The root of the machine name that we use. This is the fixed part of
# the machine name. If this has the value X, then the machines
# will be called X0, X1, X2,...
variable "nameRoot" {
  type = string
}

####################################################
# The following variables refer to SSH keys. You
# might want to change this
####################################################


# The SSH key that we will use to access our machines. This is
# the name of the key as known to DigitalOcean because we have
# uploaded the public key
variable "do_ssh_key_name" {
  type = string
  default = "do-default-key"
}

# The private key file for this key
variable "do_ssh_private_key_file" {
  type = string
  default = "~/.ssh/do-default-key"
}

####################################################
# The following variables specify the configuration
# of the machines that we bring up
###################################################

# The number of machines to provide
variable "machine_count" {
  type = number
  default = 2
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
