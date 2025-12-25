package com.aerofocus.ui.screens.booking

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.aerofocus.domain.model.City
import com.aerofocus.service.SessionService
import com.aerofocus.util.CityData
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class BookingViewModel(application: Application) : AndroidViewModel(application) {

    data class BookingState(
        val fromCity: City? = CityData.cities.firstOrNull(),
        val toCity: City? = CityData.cities.getOrNull(1),
        val durationMinutes: Int = 25,
        val customMinutes: Float = 25f
    )

    private val _state = MutableStateFlow(BookingState())
    val state: StateFlow<BookingState> = _state

    val cities: List<City> = CityData.cities
    private val appContext = application.applicationContext

    fun onFromSelected(city: City) {
        _state.update { it.copy(fromCity = city) }
    }

    fun onToSelected(city: City) {
        _state.update { it.copy(toCity = city) }
    }

    fun onDurationSelected(minutes: Int) {
        _state.update { it.copy(durationMinutes = minutes, customMinutes = minutes.toFloat()) }
    }

    fun onCustomDurationChanged(minutes: Float) {
        _state.update { it.copy(durationMinutes = minutes.toInt(), customMinutes = minutes) }
    }

    fun startSession(onStarted: () -> Unit) {
        val current = _state.value
        val from = current.fromCity ?: return
        val to = current.toCity ?: return
        viewModelScope.launch {
            SessionService.startSession(appContext, from.displayName, to.displayName, current.durationMinutes)
            onStarted()
        }
    }
}
