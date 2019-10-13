######################################################################
# Global setup
######################################################################

# Terraform settings
terraform {
  # Make sure that we have at least version 0.12
  required_version =  ">= 0.12"
  # The backend - we use PostgreSQL
  backend "pg" {
  }
}

######################################################################
# Variables. As we can only override variables on the command line
# that are known to the main module, we need to list them all here
######################################################################

# The DigitalOcean oauth token. We will set this with the
#  -var="do_token=..." command line option
variable "do_token" {}


# Call droplet module
module "droplet" {
  source = "./modules/droplet"
  do_token = var.do_token
  ansibleGroups = "['web']"
  nameRoot = "web"
}

# Call EC2 module
module "ec2Instance" {
  source = "./modules/ec2Instance"
  ansibleGroups = "['db']"
  nameRoot = "db"
}



# Collect output
output "inventory" {
  value = concat(module.droplet.inventory, module.ec2Instance.inventory)
}
