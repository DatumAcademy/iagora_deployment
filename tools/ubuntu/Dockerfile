# -- Base image --
FROM docker.io/ubuntu:22.04

# Ensure that RUN commands fail on errors at any stage in pipes.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade system packages. Install security updates, SSH server and other dependencies.
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends openssh-server sudo systemd python3 && \
    rm -rf /var/lib/apt/lists/*

# Create privileged SSH user and grant it to run sudo without password.
# hadolint ignore=DL3004
RUN useradd --shell /bin/bash -G sudo iagora && \
    echo "iagora ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/iagora

# Insert generated public SSH key into ~/.ssh/authorized_keys.
COPY ./keys/id_iagora.pub /home/iagora/.ssh/authorized_keys

# Insert generated SSH host key into /etc/ssh.
COPY ./keys/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key

# Setup permissions and create privilege separation directory.
RUN chown -R iagora:iagora /home/iagora/ && \
    chown root:root /etc/ssh/ssh_host_ed25519_key && \
    chmod 600 /home/iagora/.ssh/authorized_keys && \
    chmod 600 /etc/ssh/ssh_host_ed25519_key && \
    mkdir /var/run/sshd

# Start SSH server on container startup.
RUN systemctl enable ssh

# Run systemd at startup.
CMD [ "/usr/lib/systemd/systemd" ]
