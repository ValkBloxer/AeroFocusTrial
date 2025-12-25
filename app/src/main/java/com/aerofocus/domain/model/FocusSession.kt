package com.aerofocus.domain.model

import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

@Suppress("MagicNumber")
data class FocusSession(
    val id: Long = 0,
    val startTime: Long,
    val endTime: Long,
    val durationMinutes: Int,
    val fromCity: String,
    val toCity: String,
    val completed: Boolean
) {
    val formattedRange: String
        get() {
            val formatter = DateTimeFormatter.ofPattern("MMM d, HH:mm").withZone(ZoneId.systemDefault())
            return "${formatter.format(Instant.ofEpochMilli(startTime))} - ${formatter.format(Instant.ofEpochMilli(endTime))}"
        }
}
