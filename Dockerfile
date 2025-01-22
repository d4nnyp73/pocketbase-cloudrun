FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    ca-certificates

# Create necessary directories with proper permissions
RUN mkdir -p /pb /cloud/storage/pb_data /cloud/storage/pb_public /cloud/storage/pb_hooks && \
    chmod -R 755 /pb /cloud/storage

# Copy local PocketBase binary
COPY ./pocketbase/pocketbase /pb/

# Copy hooks if they exist
COPY ./pb_hooks/ /cloud/storage/pb_hooks/

# Make sure the binary is executable
RUN chmod +x /pb/pocketbase

# Use non-root user for better security
RUN addgroup -S pocketbase && adduser -S pocketbase -G pocketbase
RUN chown -R pocketbase:pocketbase /pb /cloud/storage

USER pocketbase

# Environment variables
ENV PORT 8080

# Start PocketBase with dynamic port binding
CMD ["/bin/sh", "-c", "/pb/pocketbase serve --http=0.0.0.0:${PORT} --dir=/cloud/storage/pb_data --publicDir=/cloud/storage/pb_public --hooksDir=/cloud/storage/pb_hooks"]
