FROM ubuntu:25.04
LABEL org.opencontainers.image.authors="radical@radical.fun" version="2.0"

# Add new user

RUN useradd -m r5reloaded

# Copy

COPY --chown=r5reloaded:r5reloaded ./server/ /home/r5reloaded/server/

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends gnupg wget -y \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O - https://dl.winehq.org/wine-builds/winehq.key \
        | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/plucky/winehq-plucky.sources \
    && apt-get update -y \
    && apt-get install --install-recommends winehq-stable -y \
    && apt-get purge --auto-remove -y gnupg wget \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Swap to new user

USER r5reloaded

WORKDIR /home/r5reloaded/server

# Expose ports

EXPOSE 37000/udp

# Define environment

ENV ARGS="" \
    NAME="An R5Reloaded Server" \
    PLAYLIST="fs_dm" \
    WINEDEBUG="-all" \
    DEBIAN_FRONTEND=noninteractive \
    WINEARCH=win64 \
    WINEPREFIX=/home/r5reloaded/server/wineprefix \
    HOME=/home/r5reloaded \
    PORT=37000

ENTRYPOINT ["sh", "-c", "exec wine r5apex_ds.exe -noconsole -port ${PORT} +launchplaylist \"${PLAYLIST}\" +hostname \"${NAME}\" ${ARGS}"]

