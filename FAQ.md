# Frequently Asked Questions (FAQ)

## General Questions

### What is OSRM?

OSRM (Open Source Routing Machine) is a high-performance routing engine for shortest paths in road networks. It's designed for road network routing using OpenStreetMap data.

### What can I do with OSRM?

- Calculate fastest routes between points
- Build navigation applications
- Create delivery route optimization systems
- Analyze road network accessibility
- Develop location-based services
- Calculate distance matrices for multiple locations

### Do I need to download the entire world?

No! You can download specific countries, regions, or even cities. The script supports granular selection from 180+ countries.

### How much disk space do I need?

It varies by region:

- Small countries (Monaco, Luxembourg): 50-200 MB
- Medium countries (Germany, Japan): 2-5 GB
- Large countries (USA, China): 10-20 GB
- Continents (Europe, Asia): 50-100 GB
- Entire planet: 150+ GB

---

## Installation & Setup

### What are the system requirements?

- **OS**: macOS, Linux, or Windows with WSL
- **Bash**: 5.0 or higher
- **Docker**: Latest version
- **Network**: Internet connection for downloading map data
- **Disk**: Varies by region (see above)

### Can I run this on Windows?

Yes! Use Windows Subsystem for Linux (WSL 2) with Docker Desktop.

### Do I need to know Docker?

Not really. The script handles all Docker commands automatically. You just need Docker installed and running.

### How do I verify Docker is working?

```bash
docker --version
docker info
```

---

## Usage Questions

### How do I download a specific country?

```bash
./setup-osrm.sh germany
```

### How do I download multiple countries?

```bash
./setup-osrm.sh france spain italy
```

### Can I download an entire continent?

```bash
./setup-osrm.sh europe
```

### How do I use a custom directory?

```bash
./setup-osrm.sh --dir /path/to/directory iran
```

### Can I skip the download if I already have the .osm.pbf file?

```bash
./setup-osrm.sh --skip-download germany
```

### How do I change the routing profile (car/bicycle/foot)?

```bash
./setup-osrm.sh --profile bicycle netherlands
```

---

## Troubleshooting

### Download keeps failing

1. **Check internet connection**
2. **Increase retry attempts**:
   ```bash
   export MAX_RETRIES=10
   ./setup-osrm.sh iran
   ```
3. **Try a smaller region first** to test connectivity
4. **Check Geofabrik status**: https://download.geofabrik.de/

### Docker permission denied

```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker
```

### Out of disk space

1. **Check available space**: `df -h`
2. **Clean Docker cache**: `docker system prune -a`
3. **Choose a smaller region**
4. **Use external storage**:
   ```bash
   export OSRM_DIR="/Volumes/ExternalDrive/osrm"
   ```

### OSRM processing fails with memory error

Increase Docker memory limit:

- Docker Desktop → Preferences → Resources → Memory
- Recommended: 4GB+ for large countries, 8GB+ for continents

### Health check fails but files exist

1. **Verify files**: Check if `osrm/map.osrm*` files exist
2. **Manual test**: Start OSRM manually and test
3. **Check coordinates**: Ensure test coordinates are within your map region
4. **Skip health check**: Use `--skip-health-check` flag

### Route calculation returns "NoRoute"

- Your coordinates are outside the downloaded map area
- Use coordinates from within your selected region
- Check if coordinates are in correct format: `longitude,latitude`

---

## Data & Updates

### How often should I update the map data?

- **Active development areas**: Monthly
- **Stable regions**: Quarterly to annually
- **Rural areas**: Less frequently

OpenStreetMap data is updated daily on Geofabrik, so you can download fresh data anytime.

### How do I update my map data?

Simply re-run the script with the same region:

```bash
./setup-osrm.sh germany
```

### Can I use multiple map regions simultaneously?

Not with a single OSRM instance. You need separate OSRM instances for each region, running on different ports.

### What's the difference between continents and countries?

- **Continent**: Downloads entire continent as one large file
- **Individual countries**: More granular, smaller files, easier to manage

---

## Performance

### How fast is OSRM?

Extremely fast! Route calculations typically take:

- Simple routes: <10ms
- Complex routes with waypoints: <50ms
- Distance matrices (10x10): <100ms

### Can I use OSRM for production?

Absolutely! OSRM is used by many production systems. Make sure to:

- Use proper Docker orchestration (Kubernetes, Swarm)
- Set up load balancing for high traffic
- Monitor resource usage
- Keep backups of processed data

### How much RAM does OSRM need?

- **Small countries**: 512MB - 1GB
- **Medium countries**: 2GB - 4GB
- **Large countries**: 8GB - 16GB
- **Continents**: 16GB - 32GB+

The entire routing graph is loaded into RAM for maximum performance.

---

## API Usage

### What API endpoints are available?

- `/route` - Calculate routes
- `/table` - Distance matrices
- `/match` - Map matching for GPS traces
- `/trip` - Traveling salesman problem
- `/nearest` - Find nearest road segment

See `examples/api-usage.md` for detailed examples.

### Is there a rate limit?

By default, no. You control the OSRM instance, so there are no external rate limits.

### Can I use OSRM with JavaScript/Python/PHP?

Yes! OSRM is a REST API, so any language with HTTP support works. See `examples/api-usage.md` for code examples.

### How do I integrate with a web map?

Use Leaflet.js or similar mapping libraries. Example:

```javascript
L.Routing.control({
  waypoints: [L.latLng(52.517037, 13.38886), L.latLng(52.529407, 13.397634)],
  router: new L.Routing.OSRMv1({
    serviceUrl: 'http://localhost:5000/route/v1',
  }),
}).addTo(map);
```

---

## Advanced Topics

### Can I customize routing profiles?

Yes! OSRM supports custom `.lua` profiles. You can create profiles optimized for:

- Heavy vehicles
- Emergency vehicles
- Avoid highways/tolls
- Accessibility routing

### How do I deploy OSRM to production?

1. **Use Docker Compose** for orchestration
2. **Set up reverse proxy** (nginx) for SSL/caching
3. **Use load balancer** for multiple instances
4. **Monitor** with Prometheus/Grafana
5. **Implement caching** (Redis) for common queries

### Can I merge multiple regions?

Yes, but you need to merge the `.osm.pbf` files before processing:

```bash
osmium merge region1.osm.pbf region2.osm.pbf -o merged.osm.pbf
```

### How do I add elevation data?

OSRM doesn't include elevation by default. You need to:

1. Download SRTM elevation data
2. Use custom Lua profiles to incorporate elevation
3. Rebuild the routing graph

---

## Legal & Licensing

### Can I use this commercially?

Yes! Both this script (MIT License) and OSRM (BSD License) are free for commercial use.

### What about OpenStreetMap data license?

OSM data is under ODbL (Open Database License). If you distribute the data, you must:

- Attribute OpenStreetMap contributors
- Keep the same license
- Make improvements available

For **using** the data (routing services), attribution is sufficient:

```
© OpenStreetMap contributors
```

### Do I need to attribute Geofabrik?

Not legally required, but good practice to acknowledge their service.

---

## Getting Help

### Where can I get more help?

- **GitHub Issues**: Bug reports and feature requests
- **OSRM Documentation**: http://project-osrm.org/docs/
- **OpenStreetMap Wiki**: https://wiki.openstreetmap.org/
- **OSRM Community**: GitHub Discussions

### How can I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines!

### Where can I find code examples?

Check the `examples/` directory for:

- Docker Compose configurations
- API usage in multiple languages
- Integration examples with Leaflet

---

## Didn't find your answer?

Open an issue on GitHub: https://github.com/mahdialavitabar/osrm-map-data-setup/issues
