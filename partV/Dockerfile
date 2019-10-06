# Use Ubuntus official image for 18.04
FROM  ubuntu:bionic

# Install ssh and sudo
RUN apt-get update && apt-get install -y openssh-server sudo

# Create sshd directory
RUN mkdir /var/run/sshd

#
# Create a user for ansible
#
RUN useradd -m ansible
#
# and add the user to /etc/sudoers
#
RUN echo "ansible      ALL = NOPASSWD: ALL" >> /etc/sudoers


# Import public key from the build context
RUN mkdir /home/ansible/.ssh
COPY --chown=ansible:ansible ansible.pub /home/ansible/.ssh/authorized_keys

#
# Start SSH daemon. We ask the server not to detach using
# the -D flag, otherwise the container would stop immediately again
CMD ["/usr/sbin/sshd", "-D"]
