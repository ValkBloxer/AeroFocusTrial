package com.aerofocus.ui.screens.booking

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AirplanemodeActive
import androidx.compose.material.icons.rounded.Timeline
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aerofocus.domain.model.City

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FlightBookingScreen(
    onStart: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: BookingViewModel = viewModel()
) {
    val state = viewModel.state.value
    var isFromExpanded by remember { mutableStateOf(false) }
    var isToExpanded by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        if (state.fromCity == null && viewModel.cities.isNotEmpty()) {
            viewModel.onFromSelected(viewModel.cities.first())
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Plan your next focus flight",
            style = MaterialTheme.typography.headlineMedium
        )

        CityDropdown(
            label = "From",
            expanded = isFromExpanded,
            onExpandedChange = { isFromExpanded = it },
            selectedCity = state.fromCity,
            cities = viewModel.cities,
            onCitySelected = { viewModel.onFromSelected(it); isFromExpanded = false }
        )
        CityDropdown(
            label = "To",
            expanded = isToExpanded,
            onExpandedChange = { isToExpanded = it },
            selectedCity = state.toCity,
            cities = viewModel.cities,
            onCitySelected = { viewModel.onToSelected(it); isToExpanded = false }
        )

        Text(text = "Duration", style = MaterialTheme.typography.titleMedium)
        DurationChips(
            selectedMinutes = state.durationMinutes,
            onSelection = viewModel::onDurationSelected
        )

        Column(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Custom: ${state.durationMinutes} min")
                Icon(Icons.Rounded.Timeline, contentDescription = null)
            }
            Slider(
                value = state.customMinutes,
                onValueChange = viewModel::onCustomDurationChanged,
                valueRange = 10f..120f,
                steps = 22
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        Button(
            onClick = { viewModel.startSession(onStart) },
            modifier = Modifier.fillMaxWidth(),
            enabled = state.fromCity != null && state.toCity != null
        ) {
            Icon(Icons.Rounded.AirplanemodeActive, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text("Start Flight")
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun CityDropdown(
    label: String,
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit,
    selectedCity: City?,
    cities: List<City>,
    onCitySelected: (City) -> Unit
) {
    ExposedDropdownMenuBox(expanded = expanded, onExpandedChange = onExpandedChange) {
        OutlinedTextField(
            value = selectedCity?.displayName ?: "",
            onValueChange = {},
            modifier = Modifier
                .menuAnchor()
                .fillMaxWidth(),
            label = { Text(label) },
            readOnly = true,
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) }
        )
        ExposedDropdownMenu(expanded = expanded, onDismissRequest = { onExpandedChange(false) }) {
            cities.forEach { city ->
                DropdownMenuItem(
                    text = { Text(city.displayName) },
                    onClick = { onCitySelected(city) }
                )
            }
        }
    }
}

@Composable
private fun DurationChips(selectedMinutes: Int, onSelection: (Int) -> Unit) {
    val durations = listOf(15, 25, 45, 60)
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        durations.forEach { minutes ->
            val active = minutes == selectedMinutes
            Box(
                modifier = Modifier
                    .weight(1f)
                    .padding(vertical = 4.dp),
                contentAlignment = Alignment.Center
            ) {
                Button(onClick = { onSelection(minutes) }, modifier = Modifier.fillMaxWidth()) {
                    Text("${minutes}m", textAlign = TextAlign.Center)
                }
            }
        }
    }
}
