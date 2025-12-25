package com.aerofocus

import android.app.Application
import com.aerofocus.data.local.AppDatabase
import com.aerofocus.data.repository.SessionRepositoryImpl
import com.aerofocus.domain.repository.SessionRepository

class AeroFocusApp : Application() {
    lateinit var repository: SessionRepository
        private set

    override fun onCreate() {
        super.onCreate()
        val database = AppDatabase.getInstance(this)
        repository = SessionRepositoryImpl(database.sessionDao())
    }
}
