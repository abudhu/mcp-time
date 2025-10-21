# -------- Stage 1: Pull the original image to source the proxy binary
FROM ghcr.io/sparfenyuk/mcp-proxy:v0.8.2 AS src

# -------- Stage 2: Ubuntu runtime
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# Base OS deps + catatonit + Python/pip for installing uv
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl bash \
      python3 python3-pip \
      catatonit \
      libgcc-s1 libstdc++6 zlib1g libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Install uv (so you can run 'uv' and 'uvx' inside the container)
RUN python3 -m pip install --no-cache-dir --upgrade pip \
 && python3 -m pip install --no-cache-dir uv

# Copy the mcp-proxy binary from the source image.
# NOTE: If the binary lives elsewhere in v0.8.2, adjust the path accordingly.
COPY --from=src /usr/local/bin/mcp-proxy /usr/local/bin/mcp-proxy
RUN chmod +x /usr/local/bin/mcp-proxy

# (Optional) non-root user
RUN useradd -m -u 10001 appuser
USER appuser

# Keep the proxy as entrypoint (per original image pattern that used catatonit + mcp-proxy)
ENTRYPOINT ["/usr/bin/catatonit","--","/usr/local/bin/mcp-proxy"]

# Provide your default flags here (can be overridden in K8s with 'args:')
CMD ["--pass-environment",
     "--host=0.0.0.0",
     "--port=8096",
     "--allow-origin=*",
     "--",
     "uvx",
     "mcp-server-time"]

# Documentation only; networking is handled by Kubernetes Service
EXPOSE 8096