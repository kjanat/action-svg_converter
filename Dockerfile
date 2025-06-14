FROM node:24-alpine

# Build argument for version (can be overridden during build)
ARG VERSION=1.0.6

# Set metadata
LABEL maintainer="poo-tracker"
LABEL description="SVG Converter - Convert SVG files to multiple formats"
LABEL version="${VERSION}"

# Copy VERSION file for runtime reference
COPY VERSION /tmp/VERSION

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
    fontconfig \
    ttf-liberation \
    ttf-dejavu \
    freetype \
    pango \
    pango-dev \
    harfbuzz \
    harfbuzz-dev \
    gtk+3.0 \
    xorg-server \
    cairo \
    cairo-dev \
    msttcorefonts-installer

# Install fonts
RUN update-ms-fonts \
    && fc-cache -f \
    && mkdir -p /etc/fonts/conf.d \
    && ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/ \
    && ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/ \
    && fc-cache -f -v

# Install Node.js dependencies globally with specific compatible version
RUN npm install -g @svgr/cli@8.1.0

# Create non-root user for security
RUN addgroup -g 1001 -S svguser && \
    adduser -S svguser -u 1001 -G svguser

# Create working directories and give access to font cache
RUN mkdir -p /app /tmp/svg-converter /github/workspace && \
    chown -R svguser:svguser /app /tmp/svg-converter /github/workspace && \
    # Give access to font cache directories
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

# Set environment variables for Inkscape and font configuration
ENV FONTCONFIG_PATH=/etc/fonts \
    PANGOCAIRO_BACKEND=fc

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
