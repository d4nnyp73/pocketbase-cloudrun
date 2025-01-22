FROM alpine:latest

RUN apk add --no-cache \
    ca-certificates

# Copy local PocketBase instance and data
COPY ./pocketbase /pb/

ENV HOST 0.0.0.0
ENV PORT 8080

# start PocketBase
EXPOSE 8080
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080", "--dir=/cloud/storage/pb_data", "--publicDir=/cloud/storage/pb_public", "--hooksDir=/cloud/storage/pb_hooks"]
