# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-04

### Added

- Initial release of OSRM Map Setup Script
- Interactive menu system for browsing and selecting regions
- Support for 180+ countries across all continents
- Parallel download capability for multiple regions
- Automatic retry logic with exponential backoff
- OSRM processing pipeline (extract, partition, customize)
- Built-in health check and verification
- Command-line argument support for automation
- Beautiful color-coded terminal UI
- Comprehensive documentation and examples
- Docker Compose configuration example
- API usage guide with multiple programming languages
- Environment variable configuration support
- Skip flags for download, processing, and health checks
- Multi-profile support (car, bicycle, foot)
- Dependency checking
- Resume capability for interrupted downloads

### Features

- **Interactive Mode**: User-friendly menu system
- **Batch Mode**: Command-line arguments for CI/CD
- **Robust Downloads**: Auto-retry with resume support
- **Flexible Configuration**: Environment variables and CLI flags
- **Docker Integration**: Seamless OSRM container usage
- **Health Verification**: Automated route calculation testing

[1.0.0]: https://github.com/mahdialavitabar/osrm-map-data-setup/releases/tag/v1.0.0
