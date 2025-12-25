package com.aerofocus.ui.screens.history

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.aerofocus.AeroFocusApp
import com.aerofocus.domain.model.FocusSession
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.util.concurrent.TimeUnit

class HistoryViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = (application as AeroFocusApp).repository

    val sessions: StateFlow<List<FocusSession>> = repository.observeSessions()
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    val totalMinutes: StateFlow<Long> = sessions.map { list ->
        list.sumOf { it.durationMinutes.toLong() }
    }.stateIn(viewModelScope, SharingStarted.Eagerly, 0L)

    val streakDays: StateFlow<Int> = sessions.map { list ->
        val nowDays = TimeUnit.MILLISECONDS.toDays(System.currentTimeMillis())
        val completedDays = list.filter { it.completed }.map { TimeUnit.MILLISECONDS.toDays(it.endTime) }.distinct()
        var streak = 0
        var dayPointer = nowDays
        while (completedDays.contains(dayPointer)) {
            streak += 1
            dayPointer -= 1
        }
        streak
    }.stateIn(viewModelScope, SharingStarted.Eagerly, 0)

    fun clearHistory() {
        viewModelScope.launch {
            repository.clearAll()
        }
    }
}
