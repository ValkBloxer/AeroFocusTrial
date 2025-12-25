package com.aerofocus.ui.screens.summary

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aerofocus.util.TimeFormatters

@Composable
fun SummaryScreen(
    onDone: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: SummaryViewModel = viewModel()
) {
    val state by viewModel.sessionState.collectAsState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(text = "Flight Summary", style = MaterialTheme.typography.headlineMedium)
        Card(
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(text = "Route", style = MaterialTheme.typography.titleMedium)
                Text(text = "${state.fromCity ?: ""} → ${state.toCity ?: ""}", fontWeight = FontWeight.Bold)
                Text(text = "Duration: ${state.durationMinutes} minutes")
                Text(text = "Completed: ${if (state.completed) "Yes" else "No"}")
                Text(text = "Elapsed: ${TimeFormatters.formatDuration(state.elapsedMillis)}")
            }
        }
        Button(onClick = onDone, modifier = Modifier.fillMaxWidth()) {
            Text("Save & Return")
        }
    }
}
