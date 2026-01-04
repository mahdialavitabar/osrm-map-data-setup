/**
 * OSRM Map Data Setup
 * Programmatic API for downloading and processing OpenStreetMap data
 */

const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const SCRIPT_PATH = path.join(__dirname, 'setup-osrm.sh');

/**
 * Run the OSRM setup with specified options
 * @param {Object} options - Configuration options
 * @param {string[]} [options.regions] - Regions/countries to download (e.g., ['germany', 'france'])
 * @param {string} [options.dir] - Output directory for OSRM files
 * @param {string} [options.profile='car'] - OSRM profile (car, bicycle, foot)
 * @param {boolean} [options.skipDownload=false] - Skip download phase
 * @param {boolean} [options.skipProcessing=false] - Skip OSRM processing phase
 * @param {boolean} [options.skipHealthCheck=false] - Skip health check verification
 * @returns {Promise<{success: boolean, code: number}>}
 */
function setup(options = {}) {
  return new Promise((resolve, reject) => {
    const args = [];

    if (options.dir) {
      args.push('--dir', options.dir);
    }

    if (options.profile) {
      args.push('--profile', options.profile);
    }

    if (options.skipDownload) {
      args.push('--skip-download');
    }

    if (options.skipProcessing) {
      args.push('--skip-processing');
    }

    if (options.skipHealthCheck) {
      args.push('--skip-health-check');
    }

    if (options.regions && options.regions.length > 0) {
      args.push(...options.regions);
    }

    const child = spawn('bash', [SCRIPT_PATH, ...args], {
      stdio: 'inherit',
      env: {
        ...process.env,
        FORCE_COLOR: '1',
      },
    });

    child.on('close', (code) => {
      resolve({ success: code === 0, code });
    });

    child.on('error', (err) => {
      reject(err);
    });
  });
}

/**
 * Download map data only (no processing)
 * @param {string[]} regions - Regions/countries to download
 * @param {string} [dir] - Output directory
 * @returns {Promise<{success: boolean, code: number}>}
 */
function download(regions, dir) {
  return setup({
    regions,
    dir,
    skipProcessing: true,
    skipHealthCheck: true,
  });
}

/**
 * Process existing map data (no download)
 * @param {string[]} regions - Regions/countries to process
 * @param {Object} [options] - Processing options
 * @param {string} [options.dir] - Directory containing .osm.pbf files
 * @param {string} [options.profile='car'] - OSRM profile
 * @returns {Promise<{success: boolean, code: number}>}
 */
function process(regions, options = {}) {
  return setup({
    regions,
    dir: options.dir,
    profile: options.profile,
    skipDownload: true,
    skipHealthCheck: true,
  });
}

/**
 * Get the version of the setup script
 * @returns {string}
 */
function getVersion() {
  try {
    const output = execSync(`bash "${SCRIPT_PATH}" --version`, {
      encoding: 'utf8',
    });
    return output.trim().replace('OSRM Map Setup Script ', '');
  } catch (e) {
    return 'unknown';
  }
}

/**
 * Check if required dependencies are available
 * @returns {{docker: boolean, curl: boolean, wget: boolean, bash: boolean}}
 */
function checkDependencies() {
  const check = (cmd) => {
    try {
      execSync(`which ${cmd}`, { stdio: 'ignore' });
      return true;
    } catch {
      return false;
    }
  };

  return {
    bash: check('bash'),
    docker: check('docker'),
    curl: check('curl'),
    wget: check('wget'),
  };
}

module.exports = {
  setup,
  download,
  process,
  getVersion,
  checkDependencies,
  SCRIPT_PATH,
};
