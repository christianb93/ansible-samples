output "inventory" {
  value = [for s in aws_instance.ec2Instance[*] : {
    # the Ansible groups to which we will assign the server
    "groups"           : var.ansibleGroups,
    "name"             : "${s.tags.name}",
    "ip"               : "${s.public_ip}",
    "ansible_ssh_user" : "ubuntu",
    "private_key_file" : "${var.ec2_ssh_private_key_file}"
  } ]
}
