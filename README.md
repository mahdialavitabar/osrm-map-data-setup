# 🗺️ OSRM Map Data Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/bash-5.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/docker-required-blue.svg)](https://www.docker.com/)

**An interactive, user-friendly bash script to download and process OpenStreetMap data for OSRM (Open Source Routing Machine) routing services.**

Perfect for developers building route optimization, navigation apps, logistics platforms, or any application requiring offline routing capabilities.

---

## ✨ Features

- 🌍 **Global Coverage** - Access 180+ countries across all continents
- 🎨 **Beautiful Interactive UI** - Intuitive menu system with color-coded navigation
- 🚀 **Parallel Downloads** - Download multiple regions simultaneously
- 🔄 **Auto-Retry Logic** - Robust download handling with exponential backoff
- ⚙️ **Automated Processing** - Automatic OSRM graph extraction, partitioning, and customization
- 🏥 **Health Checks** - Built-in verification to ensure routing service is ready
- 📊 **Progress Tracking** - Real-time feedback on download and processing status
- 🐳 **Docker-Ready** - Seamless integration with Docker-based OSRM deployments
- 💾 **Resume Support** - Continue interrupted downloads automatically

---

## 🎯 Use Cases

- **Route Optimization** - Build logistics and delivery route planning systems
- **Navigation Apps** - Create offline-capable navigation applications
- **Geospatial Analysis** - Analyze road networks and accessibility
- **Location Services** - Develop location-based services with routing
- **Research Projects** - Academic research on transportation and urban planning
- **Ride-Sharing Platforms** - Calculate optimal routes for drivers
- **Fleet Management** - Optimize vehicle routing for fleet operations

---

## 🚀 Quick Start

### Prerequisites

- **Bash** 5.0+ (comes pre-installed on macOS and most Linux distributions)
- **Docker** - [Install Docker](https://docs.docker.com/get-docker/)
- **curl** or **wget** - For downloading map data
- **Disk Space** - Varies by region (10GB - 100GB+ for large countries/continents)

### Installation

```bash
# Clone the repository
git clone https://github.com/mahdialavitabar/osrm-map-data-setup.git
cd osrm-map-data-setup

# Make the script executable
chmod +x setup-osrm.sh

# Run the interactive menu
./setup-osrm.sh
```

### Usage

#### Interactive Mode (Recommended)

Simply run the script without arguments to launch the interactive menu:

```bash
./setup-osrm.sh
```

Navigate through the beautiful menu to:

1. Select a continent
2. Choose specific countries or download entire regions
3. Add multiple selections
4. Download and process automatically

#### Command-Line Mode

For automation, scripts, or CI/CD pipelines:

```bash
# Single country
./setup-osrm.sh iran

# Multiple countries
./setup-osrm.sh germany france spain

# Entire continent
./setup-osrm.sh europe

# Mix and match
./setup-osrm.sh japan south-korea europe/monaco us-west

# Custom Geofabrik paths
./setup-osrm.sh europe/germany/berlin
```

---

## 📖 How It Works

### 1. **Data Download**

The script downloads `.osm.pbf` (Protocolbuffer Binary Format) files from [Geofabrik](https://download.geofabrik.de/), a reliable source for OpenStreetMap extracts.

### 2. **OSRM Processing**

Using Docker containers, the script processes the raw OSM data through three OSRM stages:

- **Extract** - Converts OSM data to routing graph
- **Partition** - Optimizes graph structure for fast queries
- **Customize** - Applies routing profiles (e.g., car, bike, foot)

### 3. **File Preparation**

Renames processed files to the standard `map.osrm` format for Docker Compose integration.

### 4. **Health Verification**

Validates the routing service by performing test route calculations.

---

## 📁 Project Structure

```
osrm-map-data-setup/
├── setup-osrm.sh          # Main setup script
├── README.md              # This file
├── LICENSE                # MIT License
├── CONTRIBUTING.md        # Contribution guidelines
├── .gitignore            # Git ignore patterns
├── examples/
│   ├── docker-compose.yml # Example Docker Compose configuration
│   └── api-usage.md      # OSRM API usage examples
└── osrm/                 # Output directory (created by script)
    ├── map.osrm*         # Processed routing data
    └── downloads/        # Downloaded .osm.pbf files
```

---

## 🌍 Supported Regions

### Continents

- 🌍 Africa (58 countries)
- 🧊 Antarctica (whole continent)
- 🌏 Asia (37 countries)
- 🦘 Australia & Oceania (5 countries)
- 🌴 Central America (6 countries)
- 🏰 Europe (49 countries)
- 🗽 North America (9 regions)
- 🐻 Russia (whole country)
- 🌎 South America (11 countries)

<details>
<summary>📋 View Full Country List</summary>

#### Africa

algeria, angola, benin, botswana, burkina-faso, burundi, cameroon, canary-islands, cape-verde, central-african-republic, chad, comores, congo-brazzaville, congo-democratic-republic, djibouti, egypt, equatorial-guinea, eritrea, ethiopia, gabon, gambia, ghana, guinea, guinea-bissau, ivory-coast, kenya, lesotho, liberia, libya, madagascar, malawi, mali, mauritania, mauritius, morocco, mozambique, namibia, niger, nigeria, reunion, rwanda, saint-helena-ascension-and-tristan-da-cunha, sao-tome-and-principe, senegal, seychelles, sierra-leone, somalia, south-africa, south-sudan, sudan, swaziland, tanzania, togo, tunisia, uganda, zambia, zimbabwe

#### Asia

afghanistan, armenia, azerbaijan, bangladesh, bhutan, cambodia, china, gcc-states, india, indonesia, iran, iraq, israel-and-palestine, japan, jordan, kazakhstan, kyrgyzstan, laos, lebanon, malaysia-singapore-brunei, maldives, mongolia, myanmar, nepal, north-korea, pakistan, philippines, south-korea, sri-lanka, syria, taiwan, tajikistan, thailand, turkmenistan, uzbekistan, vietnam, yemen

#### Australia & Oceania

australia, fiji, new-caledonia, new-zealand, papua-new-guinea

#### Central America

belize, cuba, guatemala, haiti-and-domrep, jamaica, nicaragua

#### Europe

albania, andorra, austria, azores, belarus, belgium, bosnia-herzegovina, bulgaria, croatia, cyprus, czech-republic, denmark, estonia, faroe-islands, finland, france, georgia, germany, great-britain, greece, hungary, iceland, ireland-and-northern-ireland, isle-of-man, italy, kosovo, latvia, liechtenstein, lithuania, luxembourg, macedonia, malta, moldova, monaco, montenegro, netherlands, norway, poland, portugal, romania, serbia, slovakia, slovenia, spain, sweden, switzerland, turkey, ukraine

#### North America

canada, greenland, mexico, us, us-midwest, us-northeast, us-pacific, us-south, us-west

#### South America

argentina, bolivia, brazil, chile, colombia, ecuador, paraguay, peru, suriname, uruguay, venezuela

</details>

---

## 🐳 Docker Integration

### Example Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  osrm:
    image: osrm/osrm-backend
    container_name: osrm-routing
    ports:
      - '5000:5000'
    volumes:
      - ./osrm:/data
    command: osrm-routed --algorithm mld /data/map.osrm
    restart: unless-stopped
```

### Start the Service

```bash
# After running setup-osrm.sh
docker-compose up -d

# Test the routing API
curl 'http://localhost:5000/route/v1/driving/13.388860,52.517037;13.397634,52.529407?overview=false'
```

---

## 🔧 Configuration

### Environment Variables

Customize behavior by setting these variables before running the script:

```bash
# Maximum download retry attempts (default: 3)
export MAX_RETRIES=5

# Initial retry delay in seconds (default: 5)
export RETRY_DELAY=10

# Custom output directory (default: ./osrm)
export OSRM_DIR="/path/to/custom/directory"
```

### Advanced Usage

```bash
# Process only, skip download (if you already have .osm.pbf files)
SKIP_DOWNLOAD=1 ./setup-osrm.sh iran

# Specify custom OSRM profile
OSRM_PROFILE=bicycle ./setup-osrm.sh netherlands
```

---

## 📊 Disk Space Requirements

Approximate disk space needed (varies by region density):

| Region Type    | Raw OSM Data | Processed OSRM | Total      |
| -------------- | ------------ | -------------- | ---------- |
| Small Country  | 50-200 MB    | 100-500 MB     | 150-700 MB |
| Medium Country | 200-1 GB     | 500 MB-2 GB    | 1-3 GB     |
| Large Country  | 1-5 GB       | 2-10 GB        | 5-15 GB    |
| Continent      | 5-30 GB      | 10-60 GB       | 20-100 GB  |

Examples:

- **Monaco**: ~20 MB total
- **Germany**: ~3 GB total
- **USA**: ~15 GB total
- **Europe**: ~50 GB total
- **Planet**: ~100+ GB total

---

## 🧪 Testing the Setup

After successful setup, test your OSRM instance:

### Route Calculation

```bash
# Replace coordinates with locations within your map region
curl 'http://localhost:5000/route/v1/driving/LON1,LAT1;LON2,LAT2?overview=false'
```

### Table Service (Distance Matrix)

```bash
curl 'http://localhost:5000/table/v1/driving/LON1,LAT1;LON2,LAT2;LON3,LAT3'
```

### Nearest Service

```bash
curl 'http://localhost:5000/nearest/v1/driving/LON,LAT'
```

See [OSRM API Documentation](http://project-osrm.org/docs/v5.24.0/api/) for complete API reference.

---

## 🐛 Troubleshooting

### Downloads Fail

**Issue**: Network timeouts or failed downloads

```bash
# Increase retry attempts
export MAX_RETRIES=10
./setup-osrm.sh iran
```

### Docker Permission Denied

**Issue**: Docker socket permission errors

```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Out of Disk Space

**Issue**: Insufficient space for large regions

```bash
# Check available space
df -h

# Clean Docker cache
docker system prune -a

# Use external drive
export OSRM_DIR="/Volumes/ExternalDrive/osrm"
```

### OSRM Processing Fails

**Issue**: Memory issues on large datasets

```bash
# Increase Docker memory limit in Docker Desktop settings
# Recommended: 4GB+ for large countries, 8GB+ for continents
```

### Route Calculation Returns Empty

**Issue**: Test coordinates outside map area

- Ensure test coordinates are within the downloaded region
- Use coordinates from major cities in your region

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Fork the repository
git clone https://github.com/mahdialavitabar/osrm-map-data-setup.git
cd osrm-map-data-setup

# Create a feature branch
git checkout -b feature/amazing-feature

# Make your changes and test
./setup-osrm.sh

# Commit and push
git commit -m "Add amazing feature"
git push origin feature/amazing-feature
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [OpenStreetMap Contributors](https://www.openstreetmap.org/) - For the incredible map data
- [Geofabrik](https://www.geofabrik.de/) - For providing reliable OSM extracts
- [Project OSRM](http://project-osrm.org/) - For the amazing routing engine
- [OSRM Backend](https://github.com/Project-OSRM/osrm-backend) - For the Docker images and tools

---

## 🔗 Useful Links

- [OSRM Documentation](http://project-osrm.org/docs/)
- [OpenStreetMap Wiki](https://wiki.openstreetmap.org/)
- [Geofabrik Download Server](https://download.geofabrik.de/)
- [OSRM Demo](http://map.project-osrm.org/)

---

## ⭐ Support

If this project helped you, please consider:

- ⭐ Starring the repository
- 🐛 Reporting bugs and requesting features via [Issues](https://github.com/mahdialavitabar/osrm-map-data-setup/issues)
- 🤝 Contributing improvements via Pull Requests
- 📢 Sharing with others who might find it useful

---

<div align="center">

**Made with ❤️ by developers, for developers**

</div>
