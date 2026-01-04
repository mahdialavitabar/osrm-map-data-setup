"""
Python OSRM Integration Example

Install: pip install requests
"""

import requests
from typing import List, Dict, Tuple, Optional

OSRM_BASE_URL = 'http://localhost:5000'


class OSRMClient:
    """Client for interacting with OSRM routing service."""

    def __init__(self, base_url: str = OSRM_BASE_URL):
        self.base_url = base_url.rstrip('/')

    def calculate_route(
        self,
        start: Tuple[float, float],
        end: Tuple[float, float],
        overview: str = 'full',
        steps: bool = False,
        geometries: str = 'geojson'
    ) -> Dict:
        """
        Calculate route between two points.

        Args:
            start: (longitude, latitude) tuple
            end: (longitude, latitude) tuple
            overview: 'full', 'simplified', or 'false'
            steps: Include turn-by-turn instructions
            geometries: 'geojson', 'polyline', or 'polyline6'

        Returns:
            Dictionary with distance, duration, geometry, and steps
        """
        coords = f"{start[0]},{start[1]};{end[0]},{end[1]}"
        url = f"{self.base_url}/route/v1/driving/{coords}"

        params = {
            'overview': overview,
            'steps': str(steps).lower(),
            'geometries': geometries
        }

        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        if data['code'] == 'Ok':
            route = data['routes'][0]
            return {
                'distance': route['distance'],  # meters
                'duration': route['duration'],  # seconds
                'geometry': route.get('geometry'),
                'steps': route['legs'][0].get('steps', [])
            }
        else:
            raise Exception(f"OSRM error: {data['code']}")

    def calculate_distance_matrix(
        self,
        locations: List[Tuple[float, float]]
    ) -> Dict:
        """
        Calculate distance/duration matrix for multiple locations.

        Args:
            locations: List of (longitude, latitude) tuples

        Returns:
            Dictionary with 2D arrays of distances and durations
        """
        coords = ';'.join([f"{lon},{lat}" for lon, lat in locations])
        url = f"{self.base_url}/table/v1/driving/{coords}"

        params = {'annotations': 'distance,duration'}

        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        if data['code'] == 'Ok':
            return {
                'distances': data['distances'],  # 2D array in meters
                'durations': data['durations']   # 2D array in seconds
            }
        else:
            raise Exception(f"OSRM error: {data['code']}")

    def find_nearest_road(
        self,
        location: Tuple[float, float],
        number: int = 1
    ) -> List[Dict]:
        """
        Find nearest road segment(s) to a coordinate.

        Args:
            location: (longitude, latitude) tuple
            number: Number of nearest roads to return

        Returns:
            List of nearest road waypoints
        """
        coords = f"{location[0]},{location[1]}"
        url = f"{self.base_url}/nearest/v1/driving/{coords}"

        params = {'number': number}

        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        if data['code'] == 'Ok':
            return data['waypoints']
        else:
            raise Exception(f"OSRM error: {data['code']}")

    def optimize_route(
        self,
        locations: List[Tuple[float, float]],
        roundtrip: bool = True,
        source: str = 'first',
        destination: str = 'last'
    ) -> Dict:
        """
        Optimize route for multiple stops (Traveling Salesman Problem).

        Args:
            locations: List of (longitude, latitude) tuples
            roundtrip: Return to starting point
            source: 'first', 'last', or 'any'
            destination: 'first', 'last', or 'any'

        Returns:
            Dictionary with optimized route details
        """
        coords = ';'.join([f"{lon},{lat}" for lon, lat in locations])
        url = f"{self.base_url}/trip/v1/driving/{coords}"

        params = {
            'roundtrip': str(roundtrip).lower(),
            'source': source,
            'destination': destination,
            'overview': 'full'
        }

        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        if data['code'] == 'Ok':
            trip = data['trips'][0]
            return {
                'distance': trip['distance'],
                'duration': trip['duration'],
                'geometry': trip.get('geometry'),
                'waypoints': data['waypoints']
            }
        else:
            raise Exception(f"OSRM error: {data['code']}")

    def match_trace(
        self,
        locations: List[Tuple[float, float]],
        timestamps: Optional[List[int]] = None
    ) -> Dict:
        """
        Match GPS trace to road network (map matching).

        Args:
            locations: List of (longitude, latitude) tuples
            timestamps: Optional Unix timestamps for each location

        Returns:
            Dictionary with matched route details
        """
        coords = ';'.join([f"{lon},{lat}" for lon, lat in locations])
        url = f"{self.base_url}/match/v1/driving/{coords}"

        params = {'overview': 'full'}
        if timestamps:
            params['timestamps'] = ';'.join(map(str, timestamps))

        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        if data['code'] == 'Ok':
            matching = data['matchings'][0]
            return {
                'distance': matching['distance'],
                'duration': matching['duration'],
                'geometry': matching.get('geometry'),
                'confidence': matching.get('confidence', 0)
            }
        else:
            raise Exception(f"OSRM error: {data['code']}")


# Example usage
def main():
    client = OSRMClient()

    try:
        # Calculate simple route
        print("Calculating route...")
        route = client.calculate_route(
            start=(13.388860, 52.517037),
            end=(13.397634, 52.529407)
        )
        print(f"Distance: {route['distance'] / 1000:.2f} km")
        print(f"Duration: {route['duration'] / 60:.2f} minutes")

        # Calculate distance matrix
        print("\nCalculating distance matrix...")
        locations = [
            (13.388860, 52.517037),
            (13.397634, 52.529407),
            (13.428555, 52.523219)
        ]
        matrix = client.calculate_distance_matrix(locations)
        print("Distance matrix (km):")
        for row in matrix['distances']:
            print([f"{d/1000:.2f}" for d in row])

        # Find nearest road
        print("\nFinding nearest road...")
        nearest = client.find_nearest_road((13.388860, 52.517037))
        print(f"Nearest road: {nearest[0].get('name', 'Unknown')}")
        print(f"Distance to road: {nearest[0]['distance']:.2f} meters")

        # Optimize delivery route
        print("\nOptimizing delivery route...")
        optimized = client.optimize_route(locations)
        print(f"Optimized total distance: {optimized['distance'] / 1000:.2f} km")
        print(f"Optimized total duration: {optimized['duration'] / 60:.2f} minutes")

    except Exception as e:
        print(f"Error: {e}")


if __name__ == '__main__':
    main()
