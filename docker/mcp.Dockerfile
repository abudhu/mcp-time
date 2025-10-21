# If you already have mcp-proxy-uv in another image, inherit from it:
FROM mcp-proxy-uv:v1

# Optional: set runtime defaults via env vars so you can still override them at `docker run -e`
ENV PORT=8096 \
    HOST=0.0.0.0 \
    ALLOW_ORIGIN=*

# Document the port (still need -p to publish)
EXPOSE 8096


# Keep the proxy + its flags fixed, and include the `--` separator here
ENTRYPOINT ["mcp-proxy-uv", "--pass-environment", "--host=0.0.0.0", "--port=8096", "--allow-origin=*", "--"]

# Default server command (can be overridden)
CMD ["uvx", "mcp-server-time"]