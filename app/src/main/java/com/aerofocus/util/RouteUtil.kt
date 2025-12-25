package com.aerofocus.util

import com.google.android.gms.maps.model.LatLng
import kotlin.math.abs

object RouteUtil {
    fun buildRoute(start: LatLng?, end: LatLng?): List<LatLng> {
        if (start == null || end == null) return emptyList()
        return listOf(start, end)
    }

    fun positionAlongRoute(route: List<LatLng>, progress: Float): LatLng? {
        if (route.size < 2) return route.firstOrNull()
        val pct = progress.coerceIn(0f, 1f)
        val start = route.first()
        val end = route.last()
        val lat = start.latitude + (end.latitude - start.latitude) * pct
        val lng = start.longitude + wrapLongitudeDelta(start.longitude, end.longitude) * pct
        val normalizedLng = normalizeLongitude(start.longitude + wrapLongitudeDelta(start.longitude, end.longitude) * pct)
        return LatLng(lat, normalizedLng)
    }

    private fun wrapLongitudeDelta(start: Double, end: Double): Double {
        val delta = end - start
        return when {
            abs(delta) <= 180 -> delta
            delta > 0 -> delta - 360
            else -> delta + 360
        }
    }

    private fun normalizeLongitude(value: Double): Double {
        var lng = value
        while (lng < -180) lng += 360
        while (lng > 180) lng -= 360
        return lng
    }
}
