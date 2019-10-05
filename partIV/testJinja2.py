import jinja2
env = jinja2.Environment(
    loader=jinja2.FileSystemLoader('.')
)
template = env.get_template('index.html.j2')
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
print(template.render(groups=groups, ansible_facts=ansible_facts))
