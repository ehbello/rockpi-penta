# Use a lightweight version of Debian as the base image
FROM debian:12-slim

# Define a build argument for the version of the package
ARG PACKAGE_VERSION=0.3.0

# Install required dependencies to download and install .deb packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            wget \
            python3-dev \
            device-tree-compiler \
    ;

# Download the .deb package using the specified version from the build argument
RUN wget -O rockpi-penta.deb \
    "https://github.com/ehbello/rockpi-penta/releases/download/v${PACKAGE_VERSION}/rockpi-penta_${PACKAGE_VERSION%-*}-1_all.deb"

# Install the downloaded .deb package
RUN dpkg -i rockpi-penta.deb || apt-get install -f -y

# Clean up the downloaded .deb file and clear apt cache to reduce image size
RUN rm -f rockpi-penta-${PACKAGE_VERSION}.deb \
    && apt-get autoremove --purge -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

ENV DEVICE_MODEL=rock_pi_4_armbian

# Set the working directory inside the container
WORKDIR /usr/share/rockpi-penta

# Set environment variables from the env file and run
CMD [ "bash", "-c", "set -a && source env/${DEVICE_MODEL}.env && set +a && python3 main.py" ]

## Build Instructions ##
# docker buildx build --platform linux/arm64 -t 127.0.0.1:5005/radxa/rockpi-penta:v0.3.0 --push .
