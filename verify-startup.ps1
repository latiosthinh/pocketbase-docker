# Startup Verification Script for PocketBase Docker Container (PowerShell)
# This script verifies that the PocketBase container starts successfully
# Requirements: 1.1, 1.5, 3.2

$ErrorActionPreference = "Stop"

$CONTAINER_NAME = "pocketbase"
$PORT = 56555
$MAX_WAIT = 30
$WAIT_INTERVAL = 2

Write-Host "=== PocketBase Startup Verification ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: Verify container is running
Write-Host "[1/3] Checking if container is running..." -ForegroundColor Yellow
try {
    $containerStatus = docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" --format "{{.Names}}"
    if ($containerStatus -eq $CONTAINER_NAME) {
        Write-Host "✓ Container '$CONTAINER_NAME' is running" -ForegroundColor Green
    } else {
        Write-Host "✗ Container '$CONTAINER_NAME' is not running" -ForegroundColor Red
        Write-Host ""
        Write-Host "Container status:"
        docker ps -a --filter "name=$CONTAINER_NAME"
        exit 1
    }
} catch {
    Write-Host "✗ Error checking container status: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check 2: Verify port is accessible
Write-Host "[2/3] Checking if port $PORT is accessible..." -ForegroundColor Yellow
$elapsed = 0
$portAccessible = $false

while ($elapsed -lt $MAX_WAIT) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("localhost", $PORT)
        $tcpClient.Close()
        $portAccessible = $true
        break
    } catch {
        Start-Sleep -Seconds $WAIT_INTERVAL
        $elapsed += $WAIT_INTERVAL
        Write-Host "  Waiting for port $PORT... ($elapsed`s/$MAX_WAIT`s)"
    }
}

if ($portAccessible) {
    Write-Host "✓ Port $PORT is accessible" -ForegroundColor Green
} else {
    Write-Host "✗ Port $PORT is not accessible after $MAX_WAIT seconds" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check 3: Verify HTTP request returns success
Write-Host "[3/3] Checking if HTTP request to localhost:$PORT returns success..." -ForegroundColor Yellow
$elapsed = 0
$httpSuccess = $false

while ($elapsed -lt $MAX_WAIT) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$PORT/" -Method Get -TimeoutSec 5 -UseBasicParsing
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq 200 -or $statusCode -eq 301 -or $statusCode -eq 302) {
            $httpSuccess = $true
            Write-Host "✓ HTTP request successful (status code: $statusCode)" -ForegroundColor Green
            break
        }
    } catch {
        $statusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "000" }
        Start-Sleep -Seconds $WAIT_INTERVAL
        $elapsed += $WAIT_INTERVAL
        Write-Host "  Waiting for HTTP response... ($elapsed`s/$MAX_WAIT`s, last status: $statusCode)"
    }
}

if (-not $httpSuccess) {
    Write-Host "✗ HTTP request failed after $MAX_WAIT seconds" -ForegroundColor Red
    Write-Host ""
    Write-Host "Container logs:"
    docker logs --tail 20 $CONTAINER_NAME
    exit 1
}

Write-Host ""
Write-Host "=== All checks passed! ===" -ForegroundColor Green
Write-Host "PocketBase is running and accessible at http://localhost:$PORT"
Write-Host ""
