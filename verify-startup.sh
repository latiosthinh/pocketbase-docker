#!/bin/bash

# Startup Verification Script for PocketBase Docker Container
# This script verifies that the PocketBase container starts successfully
# Requirements: 1.1, 1.5, 3.2

set -e

CONTAINER_NAME="pocketbase"
PORT="56555"
MAX_WAIT=30
WAIT_INTERVAL=2

echo "=== PocketBase Startup Verification ==="
echo ""

# Check 1: Verify container is running
echo "[1/3] Checking if container is running..."
if docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
    echo "✓ Container '${CONTAINER_NAME}' is running"
else
    echo "✗ Container '${CONTAINER_NAME}' is not running"
    echo ""
    echo "Container status:"
    docker ps -a --filter "name=${CONTAINER_NAME}"
    exit 1
fi

echo ""

# Check 2: Verify port is accessible
echo "[2/3] Checking if port ${PORT} is accessible..."
elapsed=0
port_accessible=false

while [ $elapsed -lt $MAX_WAIT ]; do
    if nc -z localhost ${PORT} 2>/dev/null || (echo > /dev/tcp/localhost/${PORT}) 2>/dev/null; then
        port_accessible=true
        break
    fi
    sleep $WAIT_INTERVAL
    elapsed=$((elapsed + WAIT_INTERVAL))
    echo "  Waiting for port ${PORT}... (${elapsed}s/${MAX_WAIT}s)"
done

if [ "$port_accessible" = true ]; then
    echo "✓ Port ${PORT} is accessible"
else
    echo "✗ Port ${PORT} is not accessible after ${MAX_WAIT} seconds"
    exit 1
fi

echo ""

# Check 3: Verify HTTP request returns success
echo "[3/3] Checking if HTTP request to localhost:${PORT} returns success..."
elapsed=0
http_success=false

while [ $elapsed -lt $MAX_WAIT ]; do
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT}/ 2>/dev/null || echo "000")
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "301" ] || [ "$http_code" = "302" ]; then
        http_success=true
        echo "✓ HTTP request successful (status code: ${http_code})"
        break
    fi
    
    sleep $WAIT_INTERVAL
    elapsed=$((elapsed + WAIT_INTERVAL))
    echo "  Waiting for HTTP response... (${elapsed}s/${MAX_WAIT}s, last status: ${http_code})"
done

if [ "$http_success" = false ]; then
    echo "✗ HTTP request failed after ${MAX_WAIT} seconds"
    echo ""
    echo "Container logs:"
    docker logs --tail 20 ${CONTAINER_NAME}
    exit 1
fi

echo ""
echo "=== All checks passed! ==="
echo "PocketBase is running and accessible at http://localhost:${PORT}"
echo ""
