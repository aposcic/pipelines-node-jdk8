FROM ubuntu:22.04
LABEL maintainer="Antonio Poscic <aposcic@pm.me>"

# Labels
LABEL \
    org.opencontainers.image.authors="Antonio Poscic <aposcic@pm.me>" \
    org.opencontainers.image.title="aposcic/pipelines-node-jdk8" \
    org.opencontainers.image.description="Bitbucket Pipelines image with Node.js and OpenJDK 8" \

# Install OpenJDK 8
RUN apt-get update \
    && apt-get install -y \
        openjdk-8-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install nvm with node and npm
ENV NODE_VERSION=16.16.0 \
NVM_DIR=/root/.nvm \
NVM_VERSION=0.39.3 \

RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh -o install_nvm.sh \
    && bash install_nvm.sh \
    && rm -rf install_nvm.sh \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Set node path
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

# Set the path.
ENV PATH=$NVM_DIR:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Create dirs and users
RUN mkdir -p /opt/atlassian/bitbucketci/agent/build \
    && sed -i '/[ -z \"PS1\" ] && return/a\\ncase $- in\n*i*) ;;\n*) return;;\nesac' /root/.bashrc \
    && useradd --create-home --shell /bin/bash --uid 1000 pipelines

WORKDIR /opt/atlassian/bitbucketci/agent/build
ENTRYPOINT ["/bin/bash"]
