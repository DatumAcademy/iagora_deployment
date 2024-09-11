# -- Base image --
FROM docker.io/python:3.12.0-slim

# Upgrade system packages. Install security updates, SSH client and other dependencies.
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to its latest release to speed up dependencies installation.
# hadolint ignore=DL3013,DL3042
RUN --mount=type=cache,target=/root/.cache/pip pip install --upgrade pip

WORKDIR /build

COPY requirements.txt requirements.yml /build/

# Install Python dependencies.
# hadolint ignore=DL3042
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

WORKDIR /app

# Create unprivileged SSH user running the application.
ARG PODMAN_USER=1000
RUN useradd -m --shell /bin/bash --uid ${PODMAN_USER} ansible
USER ansible

# Install Ansible collections.
RUN ansible-galaxy collection install -r /build/requirements.yml

CMD ["ansible"]
