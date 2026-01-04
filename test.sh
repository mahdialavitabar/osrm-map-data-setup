#!/bin/bash
# Quick test script for OSRM Map Setup

set -e

echo "🧪 Running OSRM Map Setup Tests..."
echo ""

# Test 1: Check bash version
echo "✓ Checking Bash version..."
if [[ ${BASH_VERSINFO[0]} -lt 5 ]]; then
    echo "❌ Bash 5.0+ required. Found: ${BASH_VERSION}"
    exit 1
fi
echo "  Found: ${BASH_VERSION}"
echo ""

# Test 2: Check Docker
echo "✓ Checking Docker..."
if ! command -v docker > /dev/null 2>&1; then
    echo "❌ Docker not found"
    exit 1
fi
docker --version
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker daemon not running"
    exit 1
fi
echo ""

# Test 3: Check curl or wget
echo "✓ Checking download tools..."
if ! command -v curl > /dev/null 2>&1 && ! command -v wget > /dev/null 2>&1; then
    echo "❌ Neither curl nor wget found"
    exit 1
fi
if command -v curl > /dev/null 2>&1; then
    echo "  Found: curl"
fi
if command -v wget > /dev/null 2>&1; then
    echo "  Found: wget"
fi
echo ""

# Test 4: Check script syntax
echo "✓ Checking script syntax..."
if bash -n ./setup-osrm.sh; then
    echo "  Syntax OK"
else
    echo "❌ Syntax errors found"
    exit 1
fi
echo ""

# Test 5: Check help option
echo "✓ Testing --help flag..."
if ./setup-osrm.sh --help > /dev/null 2>&1; then
    echo "  Help works"
else
    echo "❌ Help flag failed"
    exit 1
fi
echo ""

# Test 6: Check version option
echo "✓ Testing --version flag..."
if ./setup-osrm.sh --version > /dev/null 2>&1; then
    echo "  Version works"
else
    echo "❌ Version flag failed"
    exit 1
fi
echo ""

# Test 7: Check OSRM Docker image
echo "✓ Checking OSRM Docker image..."
if docker pull osrm/osrm-backend > /dev/null 2>&1; then
    echo "  Image available"
else
    echo "⚠️  Could not pull OSRM image (network issue?)"
fi
echo ""

echo "✅ All tests passed!"
echo ""
echo "To run a full test with a small region:"
echo "  ./setup-osrm.sh europe/monaco"
