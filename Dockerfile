FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    ca-certificates

# Create necessary directories with proper permissions
RUN mkdir -p /pb /cloud/storage/pb_data /cloud/storage/pb_public /cloud/storage/pb_hooks && \
    chmod -R 755 /pb /cloud/storage

# Copy local PocketBase instance and data
COPY ./pocketbase/pocketbase /pb/
COPY ./pocketbase/pb_data /cloud/storage/pb_data
COPY ./pb_hooks /cloud/storage/pb_hooks

# Make sure the binary is executable
RUN chmod +x /pb/pocketbase

# Use non-root user for better security
RUN addgroup -S pocketbase && adduser -S pocketbase -G pocketbase
RUN chown -R pocketbase:pocketbase /pb /cloud/storage
USER pocketbase

# Environment variables
ENV HOST 0.0.0.0
ENV PORT 8080

# Health check_
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/api/health || exit 1

EXPOSE ${PORT}

# Start PocketBase with explicit port binding
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080", "--dir=/cloud/storage/pb_data", "--publicDir=/cloud/storage/pb_public", "--hooksDir=/cloud/storage/pb_hooks"]
