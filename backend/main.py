import os
import json
from pathlib import Path
from typing import List, Dict, Any
from pathlib import Path

from fastapi import FastAPI, HTTPException
import requests

app = FastAPI(title="WheelRoute - Krakow Accessibility API")

ORS_KEY_FILE = Path(__file__).parent / ".env"
ORS_API_KEY = ORS_KEY_FILE.read_text(encoding="utf-8").strip() if ORS_KEY_FILE.exists() else ""
ORS_BASE_URL = "https://api.openrouteservice.org/v2/directions"

ANALYZED_DATA_DIR = Path("../machinelearning/analyzed_data")
COMBINED_FILE = ANALYZED_DATA_DIR / "all_zones.geojson"

FORBIDDEN_DATA_DIR = Path("forbidden_zones")


def load_all_analyzed_zones() -> Dict[str, Any]:
    if COMBINED_FILE.exists():
        with open(COMBINED_FILE, "r", encoding="utf-8") as f:
            return json.load(f)

    features = []
    if ANALYZED_DATA_DIR.exists():
        for folder in ANALYZED_DATA_DIR.iterdir():
            if folder.is_dir():
                for geojson_file in folder.glob("*.geojson"):
                    with open(geojson_file, "r", encoding="utf-8") as f:
                        data = json.load(f)
                        features.extend(data.get("features", []))

    return {
        "type": "FeatureCollection",
        "name": "Krakow_Accessibility_Zones",
        "features": features
    }


def load_strictly_forbidden_polygons() -> List[Dict[str, Any]]:
    forbidden_features = []
    if FORBIDDEN_DATA_DIR.exists():
        for geojson_file in FORBIDDEN_DATA_DIR.glob("**/*.geojson"):
            try:
                with open(geojson_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    for feat in data.get("features", []):
                        if feat.get("properties") is None:
                            feat["properties"] = {}
                        feat["properties"]["is_strictly_forbidden"] = True
                        feat["properties"]["avoid"] = True
                        forbidden_features.append(feat)
            except Exception as e:
                print(f"Error reading file {geojson_file}: {e}")

    return forbidden_features


def format_to_ors_multipolygon(features: List[Dict[str, Any]]) -> Dict[str, Any]:
    coords_list = []
    for feat in features:
        geom = feat.get("geometry", {})
        geom_type = geom.get("type")
        c = geom.get("coordinates", [])

        if geom_type == "Polygon":
            coords_list.append(c)
        elif geom_type == "MultiPolygon":
            for poly in c:
                coords_list.append(poly)

    if not coords_list:
        return None

    return {
        "type": "MultiPolygon",
        "coordinates": coords_list
    }


def get_ml_avoid_features() -> List[Dict[str, Any]]:
    zones = load_all_analyzed_zones()
    return [
        f for f in zones.get("features", [])
        if f.get("properties", {}).get("avoid") is True
        or f.get("properties", {}).get("passability_score", 1.0) < 0.4
    ]


@app.get("/api/zones")
def get_zones():
    ml_zones = load_all_analyzed_zones()
    forbidden_zones = load_strictly_forbidden_polygons()

    all_features = ml_zones.get("features", []) + forbidden_zones

    return {
        "type": "FeatureCollection",
        "name": "All_Zones_Including_Forbidden",
        "features": all_features
    }


@app.get("/api/route-standard")
def get_standard_route(start_lng: float, start_lat: float, end_lng: float, end_lat: float):
    if not ORS_API_KEY:
        raise HTTPException(status_code=503, detail="Brak konfiguracji klucza OpenRouteService.")
    c_start_lng, c_start_lat = (start_lat, start_lng) if start_lng > start_lat else (start_lng, start_lat)
    c_end_lng, c_end_lat = (end_lat, end_lng) if end_lng > end_lat else (end_lng, end_lat)

    url = f"{ORS_BASE_URL}/foot-walking/geojson"
    headers = {
        "Authorization": ORS_API_KEY,
        "Content-Type": "application/json"
    }

    payload = {
        "coordinates": [
            [c_start_lng, c_start_lat],
            [c_end_lng, c_end_lat]
        ],
        "radiuses": [1000, 1000]
    }

    forbidden_features = load_strictly_forbidden_polygons()
    forbidden_geom = format_to_ors_multipolygon(forbidden_features)

    if forbidden_geom:
        payload["options"] = {
            "avoid_polygons": forbidden_geom
        }

    response = requests.post(url, json=payload, headers=headers)
    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=f"ORS error (Standard Route): {response.text}"
        )

    data = response.json()
    feature = data["features"][0]
    summary = feature["properties"]["summary"]

    return {
        "type": "Feature",
        "properties": {
            "route_type": "standard_pedestrian",
            "distance_m": round(summary["distance"], 1),
            "time_minutes": round(summary["duration"] / 60, 1),
            "is_wheelchair_safe": False,
            "warning": "Pedestrian route (avoids closed zones, but may include stairs/rough cobblestones)"
        },
        "geometry": feature["geometry"]
    }


@app.get("/api/route")
def get_safe_wheelchair_route(start_lng: float, start_lat: float, end_lng: float, end_lat: float):
    if not ORS_API_KEY:
        raise HTTPException(status_code=503, detail="Brak konfiguracji klucza OpenRouteService.")
    c_start_lng, c_start_lat = (start_lat, start_lng) if start_lng > start_lat else (start_lng, start_lat)
    c_end_lng, c_end_lat = (end_lat, end_lng) if end_lng > end_lat else (end_lng, end_lat)

    url = f"{ORS_BASE_URL}/foot-walking/geojson"
    headers = {
        "Authorization": ORS_API_KEY,
        "Content-Type": "application/json"
    }

    payload = {
        "coordinates": [
            [c_start_lng, c_start_lat],
            [c_end_lng, c_end_lat]
        ],
        "radiuses": [1000, 1000]
    }

    ml_features = get_ml_avoid_features()
    forbidden_features = load_strictly_forbidden_polygons()
    all_avoid_features = ml_features + forbidden_features

    combined_avoid_geom = format_to_ors_multipolygon(all_avoid_features)
    if combined_avoid_geom:
        payload["options"] = {
            "avoid_polygons": combined_avoid_geom
        }

    response = requests.post(url, json=payload, headers=headers)
    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=f"ORS error (Safe Route): {response.text}"
        )

    data = response.json()
    feature = data["features"][0]
    summary = feature["properties"]["summary"]

    return {
        "type": "Feature",
        "properties": {
            "route_type": "wheelchair_safe",
            "distance_m": round(summary["distance"], 1),
            "time_minutes": round((summary["duration"] / 60) * 1.2, 1),
            "is_wheelchair_safe": True,
            "info": "Safe route: avoids architectural barriers (ML) and closed zones"
        },
        "geometry": feature["geometry"]
    }

@app.get("/api/geocode")
def geocode_address(query: str):
    if not query or len(query.strip()) < 3:
        raise HTTPException(status_code=400, detail="Query is too short.")

    search_query = query if "kraków" in query.lower() or "krakow" in query.lower() else f"{query}, Kraków"

    url = "https://nominatim.openstreetmap.org/search"
    params = {
        "q": search_query,
        "format": "json",
        "limit": 1,
        "countrycodes": "pl",
        "bounded": 1
    }
    headers = {
        "User-Agent": "CzyPrzejade-Krakow-Accessibility-App"
    }

    try:
        res = requests.get(url, params=params, headers=headers, timeout=5)
        if res.status_code == 200 and res.json():
            data = res.json()[0]
            return {
                "name": data.get("display_name"),
                "lat": float(data["lat"]),
                "lng": float(data["lon"])
            }
        else:
            raise HTTPException(status_code=404, detail="The specified address was not found in Krakow.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Geocoding service error: {str(e)}")