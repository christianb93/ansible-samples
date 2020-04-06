###############################################################################
# Variables and global configuration
###############################################################################

# The location where we search for the key for the service account
variable "gcp_service_account_key" {
  type = string
  default = "~/gcp_terraform_service_account.json"
}


# Get the ID of the project that we use from our service account key 
locals {
  key_data = jsondecode(file("${var.gcp_service_account_key}"))
}


# The region in which we bring up our resources
variable "region" {
  type = string
  default = "europe-west3"
}

# The zone in which we bring up our resources
variable "zone" {
  type = string
  default = "europe-west3-c"
}

# The file in which the public key for the vagrant user is stored
variable "vagrant_public_ssh_key_file" {
  type = string
  default = "~/.ssh/gcp-default-key.pub"
}

# The file in which the private key for the vagrant user is stored
variable "vagrant_private_ssh_key_file" {
  type = string
  default = "~/.ssh/gcp-default-key"
}


# Define provider, region, zone and project and
# specify location of credentials for the service account that we use
# Note that we extract the project ID from the service account key
provider "google" {
  credentials = "${file(var.gcp_service_account_key)}"
  project     = local.key_data.project_id
  region = var.region
  zone = var.zone
}



###############################################################################
# Networks
###############################################################################

# Create a VPC which will be our public network
resource "google_compute_network" "public-vpc" {
  name                    = "public-vpc"
  description             = "Public network, i.e. network to which all network interfaces with public IP addresses will be attached"
  auto_create_subnetworks = false
}

# Create a subnetwork within this VPC
resource "google_compute_subnetwork" "public-subnetwork" {
  name          = "public-subnetwork"
  ip_cidr_range = "192.168.100.0/24"
  network       = google_compute_network.public-vpc.self_link
  region = var.region
}

# Add firewall rules to allow incoming ICMP and SSH traffic
resource "google_compute_firewall" "public-firewall" {
  name    = "public-firewall"
  network = google_compute_network.public-vpc.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

# Create a VPC which will be our internal network
resource "google_compute_network" "internal-vpc" {
  name                    = "internal-vpc"
  description             = "Internal network"
  auto_create_subnetworks = false
}

# Create a subnetwork within this VPC
resource "google_compute_subnetwork" "internal-subnetwork" {
  name          = "internal-subnetwork"
  ip_cidr_range = "192.168.178.0/24"
  network       = google_compute_network.internal-vpc.self_link
  region        = var.region
  
}


# Add firewall rules to allow all incoming traffic on the internal network
resource "google_compute_firewall" "internal-firewall" {
  name    = "internal-firewall"
  network = google_compute_network.internal-vpc.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["192.168.178.0/24"]
  
}


###############################################################################
# Instances
###############################################################################

# Create an instance which will serve as our jump host. This instance will have two 
# network interfaces, one connected to the public network and one connected to the private
# network
resource "google_compute_instance" "jump-host" {
  name         = "jump-host"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  # We add a user vagrant with an SSH key
  metadata = {
    ssh-keys = "vagrant:${file(var.vagrant_public_ssh_key_file)}"
  }

  
  network_interface {
    # This is the public interface, attached to our public network
    network       = google_compute_network.public-vpc.self_link
    subnetwork    = google_compute_subnetwork.public-subnetwork.self_link
    access_config {
    }
  }


  network_interface {
    # This is the internal interface, attached to our internal network
    network       = google_compute_network.internal-vpc.self_link
    subnetwork    = google_compute_subnetwork.internal-subnetwork.self_link
  }
  
  # remove sshguard at startup
  metadata_startup_script = "sudo apt-get -y remove sshguard"

} 
 
# This is the target host which is connected to the private network only
resource "google_compute_instance" "target-host" {
  name         = "target-host"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  # We add a user vagrant with an SSH key
  metadata = {
    ssh-keys = "vagrant:${file(var.vagrant_public_ssh_key_file)}"
  }

  
  network_interface {
    # This is the private interface, attached to our private network
    network       = google_compute_network.internal-vpc.self_link
    subnetwork    = google_compute_subnetwork.internal-subnetwork.self_link
  }

}

###################################################################################
# Provide inventory data 
###################################################################################

output "inventory" {
  value = concat(
      [ {
        "groups"           : "['jump_hosts']",
        "name"             : "${google_compute_instance.jump-host.name}",
        "ip"               : "${google_compute_instance.jump-host.network_interface.0.access_config.0.nat_ip }",
        "ansible_ssh_user" : "vagrant",
        "private_key_file" : "${var.vagrant_private_ssh_key_file}",
        "ssh_args"         : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      } ],
      [ {
        "groups"           : "['target_hosts']",
        "name"             : "${google_compute_instance.target-host.name}",
        "ip"               : "${google_compute_instance.target-host.network_interface.0.network_ip}",
        "ansible_ssh_user" : "vagrant",
        "private_key_file" : "${var.vagrant_private_ssh_key_file}",
        "ssh_args"         : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o \"ProxyCommand ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.vagrant_private_ssh_key_file} -W %h:%p vagrant@${google_compute_instance.jump-host.network_interface.0.access_config.0.nat_ip}\""       
       }]
   )
}

