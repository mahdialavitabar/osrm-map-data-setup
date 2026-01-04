# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of OSRM Map Setup seriously. If you have discovered a security vulnerability, please follow these steps:

### 1. **Do Not** Open a Public Issue

Please **do not** create a public GitHub issue for security vulnerabilities.

### 2. Report Privately

Email security details to: **[your-email@example.com]**

Include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### 3. Response Timeline

- **24 hours**: Initial response acknowledging receipt
- **7 days**: Assessment and preliminary feedback
- **30 days**: Fix released (for confirmed vulnerabilities)

### 4. Disclosure Policy

- We request you give us reasonable time to fix the issue before public disclosure
- We will credit you in the security advisory (unless you prefer to remain anonymous)
- We will notify you when the fix is released

## Security Considerations

### Script Execution

This bash script:

- Downloads files from external sources (Geofabrik)
- Executes Docker containers
- Creates files on your system

**Best Practices:**

- Review the script before running
- Only download from trusted sources
- Ensure Docker is properly configured
- Run with least privilege necessary

### Docker Security

- Keep Docker updated to the latest version
- Don't run Docker daemon as root in production
- Use Docker security scanning for production deployments
- Review OSRM container images before use

### Network Security

- Downloads occur over HTTPS (when using curl with `-L` flag)
- Verify checksums when available
- Use firewall rules to restrict OSRM API access in production

### Data Integrity

- OSM data from Geofabrik is generally trusted
- For critical applications, verify checksums:
  ```bash
  curl -O https://download.geofabrik.de/[region]-latest.osm.pbf.md5
  md5sum -c [region]-latest.osm.pbf.md5
  ```

## Known Security Considerations

### 1. Arbitrary File Download

The script downloads files based on user input. While we validate input, always verify the source.

### 2. Docker Socket Access

Script requires Docker socket access. This is equivalent to root access. Use caution in shared environments.

### 3. Disk Space Exhaustion

Large downloads could fill disk space. Monitor disk usage in production.

### 4. OSRM API Exposure

If exposing OSRM API publicly:

- Use reverse proxy with rate limiting
- Implement authentication
- Use HTTPS
- Monitor for abuse

## Security Updates

We will announce security updates through:

- GitHub Security Advisories
- Release notes
- CHANGELOG.md

## Scope

This security policy applies to:

- The setup script (`setup-osrm.sh`)
- Documentation and examples
- Supporting files in this repository

**Not in scope:**

- OSRM backend itself (see [OSRM security](https://github.com/Project-OSRM/osrm-backend))
- Docker (see [Docker security](https://docs.docker.com/engine/security/))
- Operating system security

---

**Thank you for helping keep OSRM Map Setup secure!**
