
# Extend a current, available base tag (v0.8.x).
FROM ghcr.io/sparfenyuk/mcp-proxy:v0.8.2

# Install 'uv' so we can run `uvx mcp-server-time` inside the container
RUN python3 -m ensurepip && pip install --no-cache-dir uv

# Keep the proxy as entrypoint (per README pattern that uses catatonit + mcp-proxy)
# The base image already sets the entrypoint to mcp-proxy via catatonit.

CMD ["--pass-environment",
     "--host=0.0.0.0",
     "--port=8096",
     "--allow-origin=*",
     "--",
     "uvx",
     "mcp-server-time"]
