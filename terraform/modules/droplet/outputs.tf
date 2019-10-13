output "inventory" {
  value = [for s in digitalocean_droplet.droplet[*] : {
    # the Ansible groups to which we will assign the server
    "groups"           : var.ansibleGroups,
    "name"             : "${s.name}",
    "ip"               : "${s.ipv4_address}",
    "ansible_ssh_user" : "root",
    "private_key_file" : "${var.do_ssh_private_key_file}"
  } ]
}
