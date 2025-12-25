package com.aerofocus

import com.aerofocus.util.TimeFormatters
import org.junit.Assert.assertEquals
import org.junit.Test

class ExampleUnitTest {
    @Test
    fun formatDuration_isCorrect() {
        assertEquals("05:00", TimeFormatters.formatDuration(300_000))
    }
}
