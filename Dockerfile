FROM node:24-slim

# Build argument for version (can be overridden during build)
ARG VERSION=1.0.6

# Set metadata
LABEL maintainer="kjanat" \
    description="SVG Converter - Convert SVG files to multiple formats" \
    version="${VERSION}"

# Copy VERSION file for runtime reference
COPY VERSION /tmp/VERSION

# Enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Create non-root user early for security
RUN groupadd -g 1001 svguser && \
    useradd -u 1001 -g svguser -s /bin/bash svguser

# Create working directories and set permissions
RUN mkdir -p /app /tmp/svg-converter /github/workspace /usr/share/fonts /var/cache/fontconfig && \
    chown -R svguser:svguser /app /tmp/svg-converter /github/workspace /usr/share/fonts /var/cache/fontconfig && \
    # Create Inkscape config directories to prevent warnings
    mkdir -p /home/svguser/.config/inkscape /home/svguser/.local/share && \
    chown -R svguser:svguser /home/svguser/.config /home/svguser/.local

# Install all system dependencies in a single layer
RUN apt-get update && apt-get install -y \
    # Basic dependencies
    curl \
    ca-certificates \
    bash \
    jq \
    coreutils \
    findutils \
    wget \
    unzip \
    # Image conversion tools
    librsvg2-bin \
    imagemagick \
    inkscape \
    # Font dependencies
    fontconfig \
    fonts-liberation \
    fonts-dejavu \
    libfreetype6 \
    # Pango and HarfBuzz dependencies
    libpango1.0-0 \
    libpango1.0-dev \
    libharfbuzz0b \
    libharfbuzz-dev \
    # X11 and GTK dependencies for Inkscape
    libgtk-3-0 \
    xvfb \
    # Font rendering libraries
    libcairo2 \
    libcairo2-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Microsoft TrueType Core Fonts in a single layer
RUN set -e && \
    echo "Installing Microsoft TrueType Core Fonts..." && \
    mkdir -p /usr/share/fonts/truetype/msttcorefonts && \
    cd /tmp && \
    # Download all fonts in parallel using background processes
    wget -q https://downloads.sourceforge.net/corefonts/andale32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/arial32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/arialb32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/comic32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/courie32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/georgi32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/impact32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/times32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/trebuc32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/verdan32.exe & \
    wget -q https://downloads.sourceforge.net/corefonts/webdin32.exe & \
    wait && \
    # Extract fonts
    for exe in *.exe; do \
    unzip -j "$exe" "*.ttf" -d /usr/share/fonts/truetype/msttcorefonts/ 2>/dev/null || true; \
    done && \
    rm -f /tmp/*.exe && \
    # Configure fonts
    mkdir -p /etc/fonts/conf.d && \
    cd /etc/fonts/conf.d && \
    [ ! -f 10-sub-pixel-rgb.conf ] && ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf . || true && \
    [ ! -f 11-lcdfilter-default.conf ] && ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf . || true && \
    # Update font cache
    fc-cache -f && \
    echo "Font installation completed."

# Copy package files for dependency installation
COPY --chown=svguser:svguser package.json pnpm-lock.yaml* /app/

# Switch to app directory and install dependencies
WORKDIR /app
RUN --mount=type=cache,id=pnpm,target=/pnpm/store,uid=1001,gid=1001 \
    pnpm install --frozen-lockfile

# Copy application code after dependencies are installed
COPY --chown=svguser:svguser . /app/

# Make entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Switch to non-root user
USER svguser

# Add /app/node_modules/.bin to PATH so CLI tools are available
ENV PATH="/app/node_modules/.bin:$PATH"

# Set working directory
WORKDIR /github/workspace

# Set environment variables for font configuration and suppress warnings
ENV FONTCONFIG_PATH=/etc/fonts \
    PANGOCAIRO_BACKEND=fc \
    XDG_CONFIG_HOME=/home/svguser/.config \
    XDG_DATA_HOME=/home/svguser/.local/share \
    INKSCAPE_PROFILE_DIR=/home/svguser/.config/inkscape

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
