FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    ca-certificates \
    wget \
    unzip

# Create necessary directories with proper permissions
RUN mkdir -p /pb /cloud/storage/pb_data /cloud/storage/pb_public /cloud/storage/pb_hooks && \
    chmod -R 755 /pb /cloud/storage

# Download and install PocketBase
ARG PB_VERSION=0.22.3
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/ && \
    rm /tmp/pb.zip

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
CMD /pb/pocketbase serve --http="0.0.0.0:${PORT}" --dir=/cloud/storage/pb_data --publicDir=/cloud/storage/pb_public --hooksDir=/cloud/storage/pb_hooks
