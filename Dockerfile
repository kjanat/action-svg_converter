FROM node:24-alpine

# Build argument for version (can be overridden during build)
ARG VERSION=1.0.5

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
    findutils

# Install Node.js dependencies globally with specific compatible version
RUN npm install -g @svgr/cli@8.1.0

# Create non-root user for security
RUN addgroup -g 1001 -S svguser && \
    adduser -S svguser -u 1001 -G svguser

# Create working directories
RUN mkdir -p /app /tmp/svg-converter /github/workspace && \
    chown -R svguser:svguser /app /tmp/svg-converter /github/workspace

# Copy the enhanced entrypoint script
COPY entrypoint.sh /app/entrypoint.sh

# Make it executable and set proper permissions
RUN chmod +x /app/entrypoint.sh && \
    chown svguser:svguser /app/entrypoint.sh

# Switch to non-root user
USER svguser

# Set working directory
WORKDIR /github/workspace

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
