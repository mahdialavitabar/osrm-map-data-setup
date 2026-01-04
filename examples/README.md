# OSRM Map Setup Examples

This directory contains various examples and configurations to help you get started with OSRM.

## 📁 Files

### docker-compose.yml

Complete Docker Compose configuration for running OSRM with optional frontend UI.

**Usage:**

```bash
# After running setup-osrm.sh
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### api-usage.md

Comprehensive guide to using the OSRM API with examples in:

- cURL
- JavaScript (Fetch API)
- Python (Requests)
- Leaflet.js integration

## 🚀 Quick Start Examples

### 1. Monaco (Smallest Test Case)

Perfect for testing without large downloads:

```bash
../setup-osrm.sh europe/monaco
docker-compose up -d
```

### 2. Single Country

```bash
../setup-osrm.sh germany
docker-compose up -d
```

### 3. Multiple Regions

```bash
# Download multiple, process first one
../setup-osrm.sh france spain italy
```

### 4. Custom Directory

```bash
../setup-osrm.sh --dir /mnt/data/osrm japan
docker-compose up -d
```

## 📊 Production Deployment

### Nginx Reverse Proxy

Create `nginx.conf`:

```nginx
upstream osrm {
    server localhost:5000;
}

server {
    listen 80;
    server_name routing.example.com;

    location / {
        proxy_pass http://osrm;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        # Rate limiting
        limit_req zone=routing burst=20 nodelay;
    }
}

# Rate limit zone definition
limit_req_zone $binary_remote_addr zone=routing:10m rate=100r/m;
```

### Kubernetes Deployment

See [kubernetes-example.yaml](kubernetes-example.yaml) for a complete Kubernetes deployment configuration.

## 🔧 Advanced Configurations

### Multiple Regions on Different Ports

```yaml
version: '3.8'
services:
  osrm-germany:
    image: osrm/osrm-backend
    ports:
      - '5000:5000'
    volumes:
      - ./osrm-germany:/data
    command: osrm-routed --algorithm mld /data/map.osrm

  osrm-france:
    image: osrm/osrm-backend
    ports:
      - '5001:5000'
    volumes:
      - ./osrm-france:/data
    command: osrm-routed --algorithm mld /data/map.osrm
```

### Custom Routing Profile

If you have custom `.lua` profiles:

```bash
# Download and process with custom profile
OSRM_PROFILE=bicycle ../setup-osrm.sh netherlands

# Run with custom profile
docker run -p 5000:5000 -v "$PWD/osrm:/data" \
  osrm/osrm-backend osrm-routed --algorithm mld /data/map.osrm
```

## 📝 Integration Examples

Check out these files:

- `integration-nodejs.js` - Node.js integration example
- `integration-python.py` - Python integration example
- `integration-react.jsx` - React component example

## 💡 Tips

1. **Test with Monaco first** - It's the smallest region (~20MB)
2. **Monitor resources** - Use `docker stats` to check memory usage
3. **Cache responses** - Implement Redis for frequently-requested routes
4. **Use connection pooling** - For high-traffic applications
5. **Enable CORS** - Add CORS headers if using from web applications

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Check what's using port 5000
lsof -i :5000

# Use different port
docker run -p 5001:5000 -v "$PWD/osrm:/data" \
  osrm/osrm-backend osrm-routed --algorithm mld /data/map.osrm
```

### Container Crashes

```bash
# Check logs
docker logs osrm-routing

# Usually memory issue - increase Docker memory limit
# Or reduce region size
```

### Slow Performance

- Ensure entire graph fits in RAM
- Use SSD storage
- Enable Docker BuildKit
- Consider using CH algorithm for smaller regions

## 📚 Additional Resources

- [OSRM API Docs](http://project-osrm.org/docs/v5.24.0/api/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Leaflet Routing Machine](https://www.lrm.io/)
