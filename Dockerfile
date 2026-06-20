FROM ubuntu:26.10

LABEL maintainer="YiZhiXiaoLiuLang"
LABEL description="Ubuntu 26.10 with LXDE desktop, VNC server and noVNC web client"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Default VNC password
ENV VNC_PASSWORD=ubuntu26

# Install all required packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Desktop environment
    lxde-core \
    lxappearance \
    lxsession-default-apps \
    # VNC server
    x11vnc \
    # noVNC and websockify
    novnc \
    websockify \
    # Firefox browser
    firefox \
    # Utilities
    xterm \
    dbus-x11 \
    procps \
    locales \
    sudo \
    net-tools \
    iputils-ping \
    curl \
    wget \
    ca-certificates \
    # Pulseaudio for LXDE
    pulseaudio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create noVNC utility symlinks (some packages install them in non-standard paths)
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html 2>/dev/null || true

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# VNC display and port
ENV DISPLAY=:1
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COL_DEPTH=24

# VNC port + noVNC web port
EXPOSE 5901 6080

ENTRYPOINT ["/docker-entrypoint.sh"]
