# OSRM API Usage Examples

This guide demonstrates how to use the OSRM routing API after setting up your local OSRM instance.

## Base URL

```
http://localhost:5000
```

## API Endpoints

### 1. Route Service

Calculate the fastest route between coordinates.

**Endpoint:** `/route/v1/{profile}/{coordinates}`

#### Basic Route

```bash
curl 'http://localhost:5000/route/v1/driving/13.388860,52.517037;13.397634,52.529407'
```

#### Route with Overview

```bash
curl 'http://localhost:5000/route/v1/driving/13.388860,52.517037;13.397634,52.529407?overview=full&geometries=geojson'
```

#### Route with Steps (Turn-by-turn directions)

```bash
curl 'http://localhost:5000/route/v1/driving/13.388860,52.517037;13.397634,52.529407?steps=true&overview=full'
```

#### Multiple Waypoints

```bash
curl 'http://localhost:5000/route/v1/driving/13.388860,52.517037;13.397634,52.529407;13.428555,52.523219?overview=false'
```

#### Response Example

```json
{
  "code": "Ok",
  "routes": [{
    "distance": 1889.7,
    "duration": 294.1,
    "geometry": "...",
    "legs": [{
      "distance": 1889.7,
      "duration": 294.1,
      "steps": [...]
    }]
  }],
  "waypoints": [...]
}
```

---

### 2. Table Service (Distance Matrix)

Calculate a distance/duration matrix between all coordinate pairs.

**Endpoint:** `/table/v1/{profile}/{coordinates}`

#### Distance Matrix

```bash
curl 'http://localhost:5000/table/v1/driving/13.388860,52.517037;13.397634,52.529407;13.428555,52.523219'
```

#### With Annotations

```bash
curl 'http://localhost:5000/table/v1/driving/13.388860,52.517037;13.397634,52.529407?annotations=distance,duration'
```

#### Response Example

```json
{
  "code": "Ok",
  "durations": [
    [0, 294.1, 532.7],
    [291.7, 0, 241.6],
    [530.3, 241.6, 0]
  ],
  "distances": [
    [0, 1889.7, 3248.3],
    [1872.3, 0, 1361.2],
    [3231.9, 1361.2, 0]
  ]
}
```

---

### 3. Match Service

Match GPS traces to the road network (map matching).

**Endpoint:** `/match/v1/{profile}/{coordinates}`

#### Map Matching

```bash
curl 'http://localhost:5000/match/v1/driving/13.388860,52.517037;13.397634,52.529407;13.428555,52.523219?overview=full'
```

#### With Timestamps

```bash
curl 'http://localhost:5000/match/v1/driving/13.388860,52.517037;13.397634,52.529407?timestamps=1424684612;1424684616'
```

---

### 4. Nearest Service

Find the nearest road segment to a coordinate.

**Endpoint:** `/nearest/v1/{profile}/{coordinates}`

#### Find Nearest Road

```bash
curl 'http://localhost:5000/nearest/v1/driving/13.388860,52.517037'
```

#### Multiple Nearest Points

```bash
curl 'http://localhost:5000/nearest/v1/driving/13.388860,52.517037?number=3'
```

#### Response Example

```json
{
  "code": "Ok",
  "waypoints": [
    {
      "distance": 4.152629,
      "location": [13.388799, 52.517033],
      "name": "Friedrichstraße"
    }
  ]
}
```

---

### 5. Trip Service (Traveling Salesman Problem)

Solve the traveling salesman problem for given coordinates.

**Endpoint:** `/trip/v1/{profile}/{coordinates}`

#### Optimized Route

```bash
curl 'http://localhost:5000/trip/v1/driving/13.388860,52.517037;13.397634,52.529407;13.428555,52.523219'
```

#### Round Trip

```bash
curl 'http://localhost:5000/trip/v1/driving/13.388860,52.517037;13.397634,52.529407;13.428555,52.523219?source=first&destination=last&roundtrip=true'
```

---

## Common Parameters

| Parameter           | Description                  | Default      | Example                            |
| ------------------- | ---------------------------- | ------------ | ---------------------------------- |
| `overview`          | Route geometry detail        | `simplified` | `full`, `false`, `simplified`      |
| `geometries`        | Geometry format              | `polyline`   | `geojson`, `polyline`, `polyline6` |
| `steps`             | Turn-by-turn instructions    | `false`      | `true`, `false`                    |
| `annotations`       | Additional data              | `false`      | `duration`, `distance`, `nodes`    |
| `continue_straight` | Avoid U-turns                | `default`    | `true`, `false`                    |
| `alternatives`      | Number of alternative routes | `0`          | `1`, `2`, `3`                      |

---

## JavaScript Examples

### Using Fetch API

```javascript
// Calculate route
async function getRoute(start, end) {
  const url = `http://localhost:5000/route/v1/driving/${start[0]},${start[1]};${end[0]},${end[1]}?overview=full&geometries=geojson`;

  try {
    const response = await fetch(url);
    const data = await response.json();

    if (data.code === 'Ok') {
      const route = data.routes[0];
      console.log(`Distance: ${route.distance}m`);
      console.log(`Duration: ${route.duration}s`);
      console.log(`Geometry:`, route.geometry);
      return route;
    }
  } catch (error) {
    console.error('Error:', error);
  }
}

// Usage
getRoute([13.38886, 52.517037], [13.397634, 52.529407]);
```

### Distance Matrix

```javascript
async function getDistanceMatrix(coords) {
  const coordStr = coords.map((c) => `${c[0]},${c[1]}`).join(';');
  const url = `http://localhost:5000/table/v1/driving/${coordStr}?annotations=distance,duration`;

  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
  }
}

// Usage
const locations = [
  [13.38886, 52.517037],
  [13.397634, 52.529407],
  [13.428555, 52.523219],
];
getDistanceMatrix(locations);
```

---

## Python Examples

### Using Requests

```python
import requests

def get_route(start, end):
    """Calculate route between two points."""
    url = f"http://localhost:5000/route/v1/driving/{start[0]},{start[1]};{end[0]},{end[1]}"
    params = {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true'
    }

    response = requests.get(url, params=params)
    data = response.json()

    if data['code'] == 'Ok':
        route = data['routes'][0]
        print(f"Distance: {route['distance']}m")
        print(f"Duration: {route['duration']}s")
        return route
    else:
        print(f"Error: {data['code']}")
        return None

# Usage
start = [13.388860, 52.517037]
end = [13.397634, 52.529407]
route = get_route(start, end)
```

### Distance Matrix

```python
def get_distance_matrix(coordinates):
    """Get distance/duration matrix for multiple points."""
    coord_str = ';'.join([f"{lon},{lat}" for lon, lat in coordinates])
    url = f"http://localhost:5000/table/v1/driving/{coord_str}"
    params = {'annotations': 'distance,duration'}

    response = requests.get(url, params=params)
    return response.json()

# Usage
coords = [
    [13.388860, 52.517037],
    [13.397634, 52.529407],
    [13.428555, 52.523219]
]
matrix = get_distance_matrix(coords)
print("Distances:", matrix['distances'])
print("Durations:", matrix['durations'])
```

---

## Integration with Leaflet Map

```html
<!doctype html>
<html>
  <head>
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
      #map {
        height: 500px;
      }
    </style>
  </head>
  <body>
    <div id="map"></div>

    <script>
      // Initialize map
      const map = L.map('map').setView([52.52, 13.4], 13);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(
        map,
      );

      // Function to draw route
      async function drawRoute(start, end) {
        const url = `http://localhost:5000/route/v1/driving/${start[1]},${start[0]};${end[1]},${end[0]}?overview=full&geometries=geojson`;

        const response = await fetch(url);
        const data = await response.json();

        if (data.code === 'Ok') {
          const route = data.routes[0];

          // Draw route on map
          L.geoJSON(route.geometry, {
            style: { color: '#4285F4', weight: 5 },
          }).addTo(map);

          // Add markers
          L.marker(start).addTo(map).bindPopup('Start');
          L.marker(end).addTo(map).bindPopup('End');

          // Show route info
          console.log(`Distance: ${(route.distance / 1000).toFixed(2)} km`);
          console.log(`Duration: ${(route.duration / 60).toFixed(2)} min`);
        }
      }

      // Example: Berlin route
      drawRoute([52.517037, 13.38886], [52.529407, 13.397634]);
    </script>
  </body>
</html>
```

---

## Error Handling

Common error codes:

| Code           | Meaning                           |
| -------------- | --------------------------------- |
| `Ok`           | Request successful                |
| `NoRoute`      | No route found between points     |
| `NoSegment`    | Coordinates too far from any road |
| `InvalidQuery` | Invalid request parameters        |
| `InvalidValue` | Invalid parameter value           |

Example error response:

```json
{
  "code": "NoRoute",
  "message": "Impossible route between points"
}
```

---

## Performance Tips

1. **Use MLD algorithm** - Faster than Contraction Hierarchies (CH)
2. **Minimize waypoints** - Each additional point increases computation
3. **Use `overview=false`** - When you only need distance/duration
4. **Batch requests** - Use table service instead of multiple route calls
5. **Cache results** - Same coordinates = same results
6. **Use HTTP/2** - Enable in your client for better performance

---

## Additional Resources

- [OSRM API Documentation](http://project-osrm.org/docs/v5.24.0/api/)
- [OSRM Demo](http://map.project-osrm.org/)
- [Leaflet Routing Machine](https://www.lrm.io/)

---

**Note:** Replace coordinates in examples with locations within your downloaded map region!
