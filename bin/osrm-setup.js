#!/usr/bin/env node

/**
 * OSRM Map Data Setup CLI
 * Node.js wrapper for the bash setup script
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Get the path to the bash script
const scriptPath = path.join(__dirname, '..', 'setup-osrm.sh');

// Check if the script exists
if (!fs.existsSync(scriptPath)) {
  console.error('Error: setup-osrm.sh not found at', scriptPath);
  process.exit(1);
}

// Pass all arguments to the bash script
const args = process.argv.slice(2);

// Spawn the bash script with inherited stdio for interactive mode
const child = spawn('bash', [scriptPath, ...args], {
  stdio: 'inherit',
  env: {
    ...process.env,
    // Ensure colors work
    FORCE_COLOR: '1',
    TERM: process.env.TERM || 'xterm-256color',
  },
});

// Handle process exit
child.on('close', (code) => {
  process.exit(code || 0);
});

child.on('error', (err) => {
  if (err.code === 'ENOENT') {
    console.error('Error: bash is required to run this tool');
    console.error('Please ensure bash is installed and available in your PATH');
  } else {
    console.error('Error:', err.message);
  }
  process.exit(1);
});

// Handle signals
process.on('SIGINT', () => {
  child.kill('SIGINT');
});

process.on('SIGTERM', () => {
  child.kill('SIGTERM');
});
