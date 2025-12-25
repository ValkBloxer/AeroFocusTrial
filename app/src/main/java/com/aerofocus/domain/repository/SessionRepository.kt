package com.aerofocus.domain.repository

import com.aerofocus.domain.model.FocusSession
import kotlinx.coroutines.flow.Flow

interface SessionRepository {
    fun observeSessions(): Flow<List<FocusSession>>
    suspend fun insertSession(session: FocusSession)
    suspend fun clearAll()
}
