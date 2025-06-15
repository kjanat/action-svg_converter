FROM node:24-slim

# Build argument for version (can be overridden during build)
ARG VERSION=1.0.7

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
    useradd -u 1001 -g svguser -s /bin/bash -m svguser

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
    # Additional GTK and CSS dependencies
    libgtk2.0-dev \
    libglib2.0-dev \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create working directories and set proper permissions
RUN mkdir -p /app /tmp/svg-converter /github/workspace /usr/share/fonts /var/cache/fontconfig \
    /home/svguser/.config/inkscape /home/svguser/.local/share /home/svguser/.cache && \
    chown -R svguser:svguser /app /tmp/svg-converter /github/workspace /usr/share/fonts /var/cache/fontconfig \
    /home/svguser/.config /home/svguser/.local /home/svguser/.cache && \
    chmod -R 755 /home/svguser/.config /home/svguser/.local /home/svguser/.cache

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

# Create a minimal CSS file to resolve parsing errors
RUN mkdir -p /etc/inkscape && \
    echo "/* Minimal CSS to prevent parsing errors */" > /etc/inkscape/default.css && \
    echo "@namespace svg url(http://www.w3.org/2000/svg);" >> /etc/inkscape/default.css && \
    echo "/* Suppress font-optical-sizing warnings */" >> /etc/inkscape/default.css && \
    echo "text { font-optical-sizing: auto; }" >> /etc/inkscape/default.css

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

# Initialize Inkscape configuration to prevent runtime warnings
RUN mkdir -p /home/svguser/.config/inkscape/preferences && \
    echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' > /home/svguser/.config/inkscape/preferences.xml && \
    echo '<inkscape version="1.0" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape">' >> /home/svguser/.config/inkscape/preferences.xml && \
    echo '  <group id="preferences" inkscape:groupmode="prefs">' >> /home/svguser/.config/inkscape/preferences.xml && \
    echo '    <group id="misc" inkscape:groupmode="prefs">' >> /home/svguser/.config/inkscape/preferences.xml && \
    echo '      <group id="recent" inkscape:groupmode="prefs" max="0"/>' >> /home/svguser/.config/inkscape/preferences.xml && \
    echo '    </group>' >> /home/svguser/.config/inkscape/preferences.xml && \
    echo '  </group>' >> /home/svguser/.config/inkscape/preferences.xml && \
    echo '</inkscape>' >> /home/svguser/.config/inkscape/preferences.xml

# Add /app/node_modules/.bin to PATH so CLI tools are available
ENV PATH="/app/node_modules/.bin:$PATH"

# Set working directory
WORKDIR /github/workspace

# Set comprehensive environment variables to fix all warnings
ENV FONTCONFIG_PATH=/etc/fonts \
    PANGOCAIRO_BACKEND=fc \
    XDG_CONFIG_HOME=/home/svguser/.config \
    XDG_DATA_HOME=/home/svguser/.local/share \
    XDG_CACHE_HOME=/home/svguser/.cache \
    INKSCAPE_PROFILE_DIR=/home/svguser/.config/inkscape \
    GTK2_RC_FILES=/dev/null \
    GCONF_CONFIG_SOURCE="" \
    DISPLAY=:99 \
    INKSCAPE_DATADIR=/usr/share/inkscape

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
