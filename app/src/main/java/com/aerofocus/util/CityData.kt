package com.aerofocus.util

import com.aerofocus.domain.model.City

object CityData {
    val cities: List<City> = listOf(
        City("San Francisco", "USA", 37.7749, -122.4194),
        City("New York", "USA", 40.7128, -74.0060),
        City("London", "UK", 51.5074, -0.1278),
        City("Paris", "France", 48.8566, 2.3522),
        City("Berlin", "Germany", 52.52, 13.4050),
        City("Tokyo", "Japan", 35.6762, 139.6503),
        City("Sydney", "Australia", -33.8688, 151.2093),
        City("Singapore", "Singapore", 1.3521, 103.8198),
        City("Delhi", "India", 28.7041, 77.1025),
        City("Mumbai", "India", 19.0760, 72.8777),
        City("Bengaluru", "India", 12.9716, 77.5946),
        City("Dubai", "UAE", 25.2048, 55.2708),
        City("Toronto", "Canada", 43.6532, -79.3832),
        City("Mexico City", "Mexico", 19.4326, -99.1332),
        City("Sao Paulo", "Brazil", -23.5558, -46.6396),
        City("Johannesburg", "South Africa", -26.2041, 28.0473),
        City("Cairo", "Egypt", 30.0444, 31.2357),
        City("Seoul", "South Korea", 37.5665, 126.9780),
        City("Jakarta", "Indonesia", -6.2088, 106.8456),
        City("Lisbon", "Portugal", 38.7223, -9.1393)
    )
}
