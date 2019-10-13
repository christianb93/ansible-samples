# The provider AWS
provider "aws" {
  region  = "eu-central-1"
}

######################################################################
# Data sources and resources
######################################################################

# A datasource that we need to find the AMI ID. This will place
# the AMI ID of the latest image matching the search in
# data.aws_ami.latest_ami.image_id
data "aws_ami" "latest_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-????????"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "ec2Instance" {
  ami = data.aws_ami.latest_ami.image_id
  instance_type = "t2.micro"
  count = var.machine_count
  tags = {
    ManagedByTerraform = "true",
    name = "${var.nameRoot}${count.index}"
  }
  key_name = var.ec2_ssh_key_name
}
