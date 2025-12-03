# PocketBase Docker Setup

This project provides a Docker-based deployment for PocketBase, an open-source backend solution with embedded database, realtime subscriptions, built-in auth management, and a convenient dashboard UI.

## Prerequisites

- Docker installed on your system
- Docker Compose installed on your system

## Quick Start

1. Clone this repository or download the `docker-compose.yml` file
2. Start the PocketBase container:
   ```bash
   docker-compose up -d
   ```
3. Access the PocketBase admin UI at [http://localhost:56555](http://localhost:56555)
4. Create your admin account on first access

## Container Management

### Starting the Container

To start the PocketBase container in detached mode (runs in background):

```bash
docker-compose up -d
```

The container will start and PocketBase will be accessible on port 56555.

### Stopping the Container

To stop the PocketBase container:

```bash
docker-compose down
```

This will gracefully stop the container while preserving all data in the `./pb_data` directory.

### Restarting the Container

To restart the container:

```bash
docker-compose restart
```

### Viewing Logs

To view the container logs:

```bash
docker-compose logs
```

To follow logs in real-time:

```bash
docker-compose logs -f
```

To view only the last 100 lines:

```bash
docker-compose logs --tail=100
```

### Checking Container Status

To check if the container is running:

```bash
docker-compose ps
```

### Verifying Startup

To verify that the PocketBase container has started successfully and is accessible, use the provided verification scripts:

**On Linux/Mac:**
```bash
chmod +x verify-startup.sh
./verify-startup.sh
```

**On Windows (PowerShell):**
```powershell
.\verify-startup.ps1
```

The verification script checks:
1. Container is running
2. Port 56555 is accessible
3. HTTP requests to localhost:56555 return successfully

If all checks pass, you'll see a success message. If any check fails, the script will provide diagnostic information to help troubleshoot the issue.

## Accessing PocketBase

Once the container is running, you can access:

- **Admin UI**: [http://localhost:56555](http://localhost:56555)
- **API Endpoint**: `http://localhost:56555/api/`

On first access, you'll be prompted to create an admin account.

## Data Persistence

All PocketBase data is stored in the `./pb_data` directory on your host system. This includes:

- SQLite database (`data.db`)
- Uploaded files
- Application logs
- Configuration files

This data persists across container restarts and updates.

## Backup and Restore

### Creating a Backup

1. Stop the container:
   ```bash
   docker-compose stop
   ```

2. Copy the data directory:
   ```bash
   cp -r ./pb_data ./pb_data_backup_$(date +%Y%m%d)
   ```
   
   On Windows (PowerShell):
   ```powershell
   Copy-Item -Recurse ./pb_data ./pb_data_backup_$(Get-Date -Format "yyyyMMdd")
   ```

3. Restart the container:
   ```bash
   docker-compose start
   ```

### Restoring from Backup

1. Stop and remove the container:
   ```bash
   docker-compose down
   ```

2. Replace the data directory:
   ```bash
   rm -rf ./pb_data
   cp -r ./pb_data_backup_YYYYMMDD ./pb_data
   ```
   
   On Windows (PowerShell):
   ```powershell
   Remove-Item -Recurse -Force ./pb_data
   Copy-Item -Recurse ./pb_data_backup_YYYYMMDD ./pb_data
   ```

3. Start the container:
   ```bash
   docker-compose up -d
   ```

## Troubleshooting

### Container Fails to Start

**Problem**: Container exits immediately after starting

**Solutions**:
- Check the logs: `docker-compose logs`
- Verify Docker is running: `docker ps`
- Ensure no other service is using port 56555
- Check file permissions on `./pb_data` directory

### Port Already in Use

**Problem**: Error message about port 56555 being already allocated

**Solutions**:
- Check what's using the port:
  - Linux/Mac: `lsof -i :56555`
  - Windows: `netstat -ano | findstr :56555`
- Stop the conflicting service or change the port in `docker-compose.yml`
- To change the port, edit the `ports` section:
  ```yaml
  ports:
    - "YOUR_PORT:8090"
  ```

### Cannot Access Admin UI

**Problem**: Browser shows "connection refused" or "unable to connect"

**Solutions**:
- Verify the container is running: `docker-compose ps`
- Check if PocketBase started successfully: `docker-compose logs`
- Ensure you're using the correct URL: `http://localhost:56555`
- Try accessing from `http://127.0.0.1:56555`
- Check firewall settings

### Permission Denied Errors

**Problem**: Container logs show permission errors accessing `/pb/pb_data`

**Solutions**:
- On Linux, ensure proper ownership:
  ```bash
  sudo chown -R $USER:$USER ./pb_data
  ```
- Check directory permissions:
  ```bash
  chmod -R 755 ./pb_data
  ```

### Data Not Persisting

**Problem**: Data disappears after container restart

**Solutions**:
- Verify the volume mount in `docker-compose.yml`:
  ```yaml
  volumes:
    - ./pb_data:/pb/pb_data
  ```
- Check that `./pb_data` directory exists and is writable
- Ensure you're using `docker-compose down` (not `docker-compose down -v` which removes volumes)

### Container Keeps Restarting

**Problem**: Container is in a restart loop

**Solutions**:
- Check logs for error messages: `docker-compose logs`
- Verify the PocketBase image is valid: `docker-compose pull`
- Check for corrupted database in `./pb_data/data.db`
- Try with a fresh data directory (backup first!)

### Slow Performance

**Problem**: PocketBase responds slowly

**Solutions**:
- Ensure `./pb_data` is on SSD storage (not network drive)
- Check Docker resource limits (CPU, memory)
- Monitor disk I/O: `docker stats pocketbase`
- Consider optimizing the SQLite database (run VACUUM)

### Cannot Create Admin User

**Problem**: Admin creation page doesn't work or shows errors

**Solutions**:
- Clear browser cache and cookies
- Try a different browser
- Check console logs in browser developer tools
- Verify container logs for backend errors: `docker-compose logs`

## Updating PocketBase

To update to the latest version of PocketBase:

1. Backup your data (see Backup section above)

2. Pull the latest image:
   ```bash
   docker-compose pull
   ```

3. Restart the container:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

Your data will be preserved during the update.

## Configuration

The default configuration uses:
- **Host Port**: 56555
- **Container Port**: 8090 (internal)
- **Data Directory**: `./pb_data`
- **Restart Policy**: unless-stopped
- **Container Name**: pocketbase

To modify these settings, edit the `docker-compose.yml` file.

## Security Considerations

- The admin interface is exposed without authentication on first run
- For production use, consider:
  - Setting up a reverse proxy with HTTPS (nginx, Caddy)
  - Restricting port access with firewall rules
  - Using strong admin passwords
  - Regular backups of the `./pb_data` directory

## Additional Resources

- [PocketBase Documentation](https://pocketbase.io/docs/)
- [PocketBase GitHub](https://github.com/pocketbase/pocketbase)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## Support

For issues specific to:
- **PocketBase**: Visit the [PocketBase GitHub Issues](https://github.com/pocketbase/pocketbase/issues)
- **Docker**: Check [Docker Documentation](https://docs.docker.com/)
- **This Setup**: Review the troubleshooting section above
