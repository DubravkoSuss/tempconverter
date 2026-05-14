#!/bin/bash

echo "=== Container Resource Usage ==="
echo "Container Stats:"
podman stats --no-stream 2>/dev/null || docker stats --no-stream 2>/dev/null

echo ""
echo "=== Memory Usage Summary ==="
echo "Container Memory:"
podman ps --format "{{.Names}}" 2>/dev/null | while read container; do
    mem=$(podman stats --no-stream --format "{{.MemUsage}}" "$container" 2>/dev/null)
    echo "$container: $mem"
done

echo ""
echo "=== Comparison with VM ==="
echo "Typical VM Requirements:"
echo "- Memory: 512 MB - 2 GB minimum"
echo "- CPU: 1-2 vCPUs dedicated"
echo "- Disk: 10+ GB"
echo "- Boot time: 1-3 minutes"
echo ""
echo "Container Requirements:"
echo "- Memory: 50-150 MB per container"
echo "- CPU: Shared, minimal overhead"
echo "- Disk: ~200 MB (image layer)"
echo "- Boot time: 1-5 seconds"
