package com.aerofocus.ui.screens.summary

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.aerofocus.domain.model.SessionState
import com.aerofocus.service.SessionService
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class SummaryViewModel(application: Application) : AndroidViewModel(application) {
    val sessionState: StateFlow<SessionState> = SessionService.stateFlow
        .stateIn(viewModelScope, SharingStarted.Eagerly, SessionState())
}
