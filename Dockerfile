FROM node:24-alpine

# Build argument for version (can be overridden during build)
ARG VERSION=1.0.6

# Set metadata
LABEL maintainer="poo-tracker"
LABEL description="SVG Converter - Convert SVG files to multiple formats"
LABEL version="${VERSION}"

# Copy VERSION file for runtime reference
COPY VERSION /tmp/VERSION

# Copy package files
COPY package.json pnpm-lock.yaml* /app/

# Install node dependencies
RUN apk add --no-cache \
    curl \
    ca-certificates

# Enable and prepare pnpm via Corepack (uses the official release)
RUN corepack enable \
    && corepack prepare pnpm@$(node -p "require('./package.json').packageManager.split('@')[1]") --activate

# Install Node.js dependencies globally with specific compatible version
RUN cd /app && pnpm install --frozen-lockfile

# Install system dependencies for image conversion and enhanced script features
# Use imagemagick6 for better compatibility, or imagemagick for v7
RUN apk add --no-cache \
    librsvg \
    imagemagick \
    bash \
    jq \
    coreutils \
    findutils \
    inkscape \
    # Font dependencies
    fontconfig \
    ttf-liberation \
    ttf-dejavu \
    freetype \
    # Pango and HarfBuzz dependencies
    pango \
    pango-dev \
    harfbuzz \
    harfbuzz-dev \
    # X11 and GTK dependencies for Inkscape
    gtk+3.0 \
    xorg-server \
    # Font rendering libraries
    cairo \
    cairo-dev \
    # Microsoft fonts installer
    msttcorefonts-installer

# Set up font configuration and install fonts
RUN set -e \
    && echo "Installing Microsoft TrueType Core Fonts..." \
    && update-ms-fonts \
    && echo "Updating font cache..." \
    && fc-cache -f \
    && echo "Setting up font configuration..." \
    && mkdir -p /etc/fonts/conf.d \
    && cd /etc/fonts/conf.d \
    && echo "Configuring subpixel rendering..." \
    && [ ! -f 10-sub-pixel-rgb.conf ] && ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf . || true \
    && [ ! -f 11-lcdfilter-default.conf ] && ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf . || true \
    && echo "Rebuilding font cache..." \
    && fc-cache -f -v \
    && echo "Font installation and configuration completed."

# Create non-root user for security
RUN addgroup -g 1001 -S svguser && \
    adduser -S svguser -u 1001 -G svguser

# Create working directories and set permissions
RUN mkdir -p /app /tmp/svg-converter /github/workspace && \
    chown -R svguser:svguser /app /tmp/svg-converter /github/workspace && \
    # Font directories
    mkdir -p /usr/share/fonts /var/cache/fontconfig && \
    chown -R svguser:svguser /usr/share/fonts /var/cache/fontconfig

# Copy the enhanced entrypoint script
COPY entrypoint.sh /app/entrypoint.sh

# Make it executable and set proper permissions
RUN chmod +x /app/entrypoint.sh && \
    chown svguser:svguser /app/entrypoint.sh

# Switch to non-root user
USER svguser

# Set working directory
WORKDIR /github/workspace

# Set environment variables for font configuration
ENV FONTCONFIG_PATH=/etc/fonts \
    PANGOCAIRO_BACKEND=fc

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
