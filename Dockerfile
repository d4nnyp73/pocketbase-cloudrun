FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    ca-certificates

# Create necessary directories with proper permissions
RUN mkdir -p /pb /cloud/storage/pb_data /cloud/storage/pb_public /cloud/storage/pb_hooks && \
    chmod -R 755 /pb /cloud/storage

# Copy local PocketBase binary and data
COPY ./pocketbase/pocketbase /pb/
COPY ./pocketbase/pb_data/ /cloud/storage/pb_data/
COPY ./pb_hooks/ /cloud/storage/pb_hooks/

# Make sure the binary is executable
RUN chmod +x /pb/pocketbase

# Use non-root user for better security
RUN addgroup -S pocketbase && adduser -S pocketbase -G pocketbase
RUN chown -R pocketbase:pocketbase /pb /cloud/storage

# Set proper permissions for SQLite files
RUN chmod 644 /cloud/storage/pb_data/*.db* || true

USER pocketbase

# Environment variables
ENV PORT 8080

# Start PocketBase with dynamic port binding
CMD ["/bin/sh", "-c", "/pb/pocketbase serve --http=0.0.0.0:${PORT} --dir=/cloud/storage/pb_data --publicDir=/cloud/storage/pb_public --hooksDir=/cloud/storage/pb_hooks"]
