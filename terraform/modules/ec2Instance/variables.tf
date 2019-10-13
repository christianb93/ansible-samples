###################################################
# First, there is a couple of variables that do
# not have a default and that need to be provided
# when invoking the module
###################################################


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
# the name of the key as known to AWS
variable "ec2_ssh_key_name" {
  type = string
  default = "ec2-default-key"
}

# The private key file for this key, usually
# a PEM file
variable "ec2_ssh_private_key_file" {
  type = string
  default = "~/.ssh/ec2-default-key.pem"
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
