package com.aerofocus.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.aerofocus.AeroFocusApp
import com.aerofocus.R
import com.aerofocus.domain.model.FocusSession
import com.aerofocus.domain.model.SessionState
import com.aerofocus.domain.model.SessionStatus
import com.aerofocus.domain.repository.SessionRepository
import com.aerofocus.util.TimeFormatters
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.math.max

class SessionService : Service() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private var tickerJob: Job? = null
    private lateinit var notificationManager: NotificationManager
    private var repository: SessionRepository? = null

    override fun onCreate() {
        super.onCreate()
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        repository = (application as? AeroFocusApp)?.repository
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> handleStart(intent)
            ACTION_PAUSE -> pauseTimer()
            ACTION_RESUME -> resumeTimer()
            ACTION_END -> endSession(completed = false)
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }

    private fun handleStart(intent: Intent) {
        val fromCity = intent.getStringExtra(EXTRA_FROM) ?: return
        val toCity = intent.getStringExtra(EXTRA_TO) ?: return
        val durationMinutes = intent.getIntExtra(EXTRA_DURATION, 25)
        val startTime = System.currentTimeMillis()
        val endTime = startTime + durationMinutes * 60_000L

        updateState(
            SessionState(
                status = SessionStatus.Running,
                startTime = startTime,
                endTime = endTime,
                durationMinutes = durationMinutes,
                fromCity = fromCity,
                toCity = toCity,
                elapsedMillis = 0L,
                remainingMillis = durationMinutes * 60_000L,
                completed = false
            )
        )

        startForeground(NOTIFICATION_ID, buildNotification(stateFlow.value))
        startTicker()
    }

    private fun pauseTimer() {
        tickerJob?.cancel()
        updateState(stateFlow.value.copy(status = SessionStatus.Paused))
        notifyUpdate()
    }

    private fun resumeTimer() {
        if (stateFlow.value.status == SessionStatus.Paused) {
            updateState(stateFlow.value.copy(status = SessionStatus.Running))
            startTicker()
        }
    }

    private fun endSession(completed: Boolean) {
        tickerJob?.cancel()
        val current = stateFlow.value
        val endTime = System.currentTimeMillis()
        val elapsed = (endTime - (current.startTime ?: endTime)).coerceAtMost(current.durationMinutes * 60_000L)
        val updated = current.copy(
            status = if (completed) SessionStatus.Completed else SessionStatus.Ended,
            completed = completed,
            elapsedMillis = elapsed,
            remainingMillis = max(0L, (current.durationMinutes * 60_000L) - elapsed),
            endTime = endTime
        )
        updateState(updated)
        notifyUpdate()
        scope.launch {
            repository?.insertSession(
                FocusSession(
                    startTime = updated.startTime ?: endTime,
                    endTime = updated.endTime ?: endTime,
                    durationMinutes = updated.durationMinutes,
                    fromCity = updated.fromCity.orEmpty(),
                    toCity = updated.toCity.orEmpty(),
                    completed = updated.completed
                )
            )
        }
        stopForeground(STOP_REMOVE)
        stopSelf()
    }

    private fun startTicker() {
        tickerJob?.cancel()
        tickerJob = scope.launch {
            while (true) {
                val state = stateFlow.value
                val startTime = state.startTime ?: System.currentTimeMillis()
                val now = System.currentTimeMillis()
                val elapsed = now - startTime
                val totalMillis = state.durationMinutes * 60_000L
                val remaining = max(0L, totalMillis - elapsed)
                if (remaining <= 0) {
                    endSession(completed = true)
                    return@launch
                }
                updateState(
                    state.copy(
                        status = SessionStatus.Running,
                        elapsedMillis = elapsed,
                        remainingMillis = remaining
                    )
                )
                notifyUpdate()
                delay(1_000L)
            }
        }
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_LOW
        )
        notificationManager.createNotificationChannel(channel)
    }

    private fun buildNotification(state: SessionState): Notification {
        val remainingText = TimeFormatters.formatDuration(state.remainingMillis)
        val route = if (state.fromCity != null && state.toCity != null) "${state.fromCity} → ${state.toCity}" else getString(R.string.app_name)
        val content = if (state.status == SessionStatus.Completed) {
            getString(R.string.notification_completed)
        } else {
            getString(R.string.notification_inflight, remainingText)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_plane)
            .setContentTitle(route)
            .setContentText(content)
            .setOngoing(state.status == SessionStatus.Running || state.status == SessionStatus.Paused)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun notifyUpdate() {
        notificationManager.notify(NOTIFICATION_ID, buildNotification(stateFlow.value))
    }

    private fun updateState(state: SessionState) {
        stateHolder.value = state
    }

    companion object {
        private const val CHANNEL_ID = "session_channel"
        private const val NOTIFICATION_ID = 33
        private const val ACTION_START = "com.aerofocus.START"
        private const val ACTION_PAUSE = "com.aerofocus.PAUSE"
        private const val ACTION_RESUME = "com.aerofocus.RESUME"
        private const val ACTION_END = "com.aerofocus.END"
        private const val EXTRA_FROM = "extra_from"
        private const val EXTRA_TO = "extra_to"
        private const val EXTRA_DURATION = "extra_duration"

        private val stateHolder = MutableStateFlow(SessionState())
        val stateFlow = stateHolder.asStateFlow()

        fun startSession(context: Context, from: String, to: String, durationMinutes: Int) {
            val intent = Intent(context, SessionService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_FROM, from)
                putExtra(EXTRA_TO, to)
                putExtra(EXTRA_DURATION, durationMinutes)
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun pause(context: Context) {
            val intent = Intent(context, SessionService::class.java).apply { action = ACTION_PAUSE }
            ContextCompat.startForegroundService(context, intent)
        }

        fun resume(context: Context) {
            val intent = Intent(context, SessionService::class.java).apply { action = ACTION_RESUME }
            ContextCompat.startForegroundService(context, intent)
        }

        fun end(context: Context) {
            val intent = Intent(context, SessionService::class.java).apply { action = ACTION_END }
            ContextCompat.startForegroundService(context, intent)
        }
    }
}
