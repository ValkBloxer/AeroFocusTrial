package com.aerofocus.data.repository

import com.aerofocus.data.local.FocusSessionEntity
import com.aerofocus.data.local.SessionDao
import com.aerofocus.domain.model.FocusSession
import com.aerofocus.domain.repository.SessionRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class SessionRepositoryImpl(private val dao: SessionDao) : SessionRepository {
    override fun observeSessions(): Flow<List<FocusSession>> = dao.observeSessions().map { list ->
        list.map { entity ->
            FocusSession(
                id = entity.id,
                startTime = entity.startTime,
                endTime = entity.endTime,
                durationMinutes = entity.durationMinutes,
                fromCity = entity.fromCity,
                toCity = entity.toCity,
                completed = entity.completed
            )
        }
    }

    override suspend fun insertSession(session: FocusSession) {
        dao.insertSession(
            FocusSessionEntity(
                id = session.id,
                startTime = session.startTime,
                endTime = session.endTime,
                durationMinutes = session.durationMinutes,
                fromCity = session.fromCity,
                toCity = session.toCity,
                completed = session.completed
            )
        )
    }

    override suspend fun clearAll() {
        dao.clearAll()
    }
}
