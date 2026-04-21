# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container to /home/vscode
WORKDIR /home/vscode

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    ssh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Ansible and related tools
RUN pip install --no-cache-dir \
    ansible-core==2.16.7 \
    ansible-lint \
    molecule \
    docker \
    molecule[docker] \
    testinfra

ENV ARISTA_AVD_DIR="/usr/share/ansible/collections/ansible_collections"
# Install netscaler.adc collection
RUN ansible-galaxy collection install "arista.avd:>=5.0.0,<6.0.0" -p /usr/share/ansible/collections && \
    pip3 install -r ${ARISTA_AVD_DIR}/arista/avd/requirements.txt && \
    pip3 install ruamel-yaml && \
    pip3 install black && \
    pip3 install md-toc==8.2.3 && \
    pip3 install paramiko


# Set up non-root user for VSCode
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 -m vscode \
    && mkdir -p /home/vscode/.vscode-server/extensions \
    && chown -R vscode:vscode /home/vscode

# Make sure the non-root user has the rights to use sudo without password
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER vscode

# Set environment variables for non-root user
ENV PATH="/home/vscode/.local/bin:${PATH}"

# Default command when container starts
CMD ["/bin/bash"]