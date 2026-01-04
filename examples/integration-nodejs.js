/**
 * Node.js OSRM Integration Example
 *
 * Install: npm install axios
 */

const axios = require('axios');

const OSRM_BASE_URL = 'http://localhost:5000';

/**
 * Calculate route between two points
 */
async function calculateRoute(start, end, options = {}) {
  const { overview = 'full', steps = false, geometries = 'geojson' } = options;

  const coords = `${start.lon},${start.lat};${end.lon},${end.lat}`;
  const url = `${OSRM_BASE_URL}/route/v1/driving/${coords}`;

  try {
    const response = await axios.get(url, {
      params: { overview, steps, geometries },
    });

    if (response.data.code === 'Ok') {
      const route = response.data.routes[0];
      return {
        distance: route.distance, // meters
        duration: route.duration, // seconds
        geometry: route.geometry,
        steps: route.legs[0].steps || [],
      };
    } else {
      throw new Error(`OSRM error: ${response.data.code}`);
    }
  } catch (error) {
    console.error('Route calculation failed:', error.message);
    throw error;
  }
}

/**
 * Calculate distance matrix for multiple locations
 */
async function calculateDistanceMatrix(locations) {
  const coords = locations.map((loc) => `${loc.lon},${loc.lat}`).join(';');

  const url = `${OSRM_BASE_URL}/table/v1/driving/${coords}`;

  try {
    const response = await axios.get(url, {
      params: { annotations: 'distance,duration' },
    });

    if (response.data.code === 'Ok') {
      return {
        distances: response.data.distances, // 2D array in meters
        durations: response.data.durations, // 2D array in seconds
      };
    } else {
      throw new Error(`OSRM error: ${response.data.code}`);
    }
  } catch (error) {
    console.error('Distance matrix calculation failed:', error.message);
    throw error;
  }
}

/**
 * Find nearest road to a coordinate
 */
async function findNearestRoad(location, number = 1) {
  const coords = `${location.lon},${location.lat}`;
  const url = `${OSRM_BASE_URL}/nearest/v1/driving/${coords}`;

  try {
    const response = await axios.get(url, {
      params: { number },
    });

    if (response.data.code === 'Ok') {
      return response.data.waypoints;
    } else {
      throw new Error(`OSRM error: ${response.data.code}`);
    }
  } catch (error) {
    console.error('Nearest road search failed:', error.message);
    throw error;
  }
}

/**
 * Optimize route for multiple stops (Traveling Salesman Problem)
 */
async function optimizeRoute(locations, options = {}) {
  const { roundtrip = true, source = 'first', destination = 'last' } = options;

  const coords = locations.map((loc) => `${loc.lon},${loc.lat}`).join(';');

  const url = `${OSRM_BASE_URL}/trip/v1/driving/${coords}`;

  try {
    const response = await axios.get(url, {
      params: { roundtrip, source, destination, overview: 'full' },
    });

    if (response.data.code === 'Ok') {
      const trip = response.data.trips[0];
      return {
        distance: trip.distance,
        duration: trip.duration,
        geometry: trip.geometry,
        waypoints: response.data.waypoints,
      };
    } else {
      throw new Error(`OSRM error: ${response.data.code}`);
    }
  } catch (error) {
    console.error('Route optimization failed:', error.message);
    throw error;
  }
}

// Example usage
async function main() {
  try {
    // Calculate simple route
    console.log('Calculating route...');
    const route = await calculateRoute(
      { lon: 13.38886, lat: 52.517037 },
      { lon: 13.397634, lat: 52.529407 },
    );
    console.log(`Distance: ${(route.distance / 1000).toFixed(2)} km`);
    console.log(`Duration: ${(route.duration / 60).toFixed(2)} minutes`);

    // Calculate distance matrix
    console.log('\nCalculating distance matrix...');
    const locations = [
      { lon: 13.38886, lat: 52.517037 },
      { lon: 13.397634, lat: 52.529407 },
      { lon: 13.428555, lat: 52.523219 },
    ];
    const matrix = await calculateDistanceMatrix(locations);
    console.log('Distance matrix:', matrix.distances);

    // Find nearest road
    console.log('\nFinding nearest road...');
    const nearest = await findNearestRoad({ lon: 13.38886, lat: 52.517037 });
    console.log('Nearest road:', nearest[0].name);

    // Optimize delivery route
    console.log('\nOptimizing delivery route...');
    const optimized = await optimizeRoute(locations);
    console.log(
      `Optimized total distance: ${(optimized.distance / 1000).toFixed(2)} km`,
    );
  } catch (error) {
    console.error('Error:', error.message);
  }
}

if (require.main === module) {
  main();
}

module.exports = {
  calculateRoute,
  calculateDistanceMatrix,
  findNearestRoad,
  optimizeRoute,
};
