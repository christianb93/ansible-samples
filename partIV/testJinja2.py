import jinja2
#
# Create a Jinja2 environment, using the file system loader
# to be able to load templates from the local file system
#
env = jinja2.Environment(
    loader=jinja2.FileSystemLoader('.')
)
#
# Load our template
#
template = env.get_template('index.html.j2')
#
# Prepare the input variables, as Ansible would to it (use ansible -m setup to see
# how this structure looks like, you can even copy the JSON output)
#
groups = {'all': ['127.0.0.1', '192.168.33.44']}
ansible_facts={
        "all_ipv4_addresses": [
            "10.0.2.15",
            "192.168.33.10"
        ],
        "env": {
            "HOME": "/home/vagrant",
        },
        "interfaces": [
            "enp0s8"
        ],
        "enp0s8": {
            "ipv4": {
                "address": "192.168.33.11",
                "broadcast": "192.168.33.255",
                "netmask": "255.255.255.0",
                "network": "192.168.33.0"
            },
            "macaddress": "08:00:27:77:1a:9c",
            "type": "ether"
        },
}
#
# Render the template and print the output
#
print(template.render(groups=groups, ansible_facts=ansible_facts))
