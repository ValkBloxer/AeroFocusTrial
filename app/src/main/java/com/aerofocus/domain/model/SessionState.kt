package com.aerofocus.domain.model

data class SessionState(
    val status: SessionStatus = SessionStatus.Idle,
    val startTime: Long? = null,
    val endTime: Long? = null,
    val durationMinutes: Int = 0,
    val fromCity: String? = null,
    val toCity: String? = null,
    val elapsedMillis: Long = 0L,
    val remainingMillis: Long = 0L,
    val completed: Boolean = false
) {
    val progress: Float
        get() = if (durationMinutes == 0) 0f else (elapsedMillis.toFloat() / (durationMinutes * 60_000f)).coerceIn(0f, 1f)
}

enum class SessionStatus { Idle, Running, Paused, Ended, Completed }
