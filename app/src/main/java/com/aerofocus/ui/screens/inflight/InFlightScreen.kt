package com.aerofocus.ui.screens.inflight

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Flag
import androidx.compose.material.icons.rounded.Pause
import androidx.compose.material.icons.rounded.PlayArrow
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.layout.ContentScale
import com.aerofocus.domain.model.SessionStatus
import com.aerofocus.service.SessionService
import com.aerofocus.ui.theme.CloudWhite
import com.aerofocus.util.RouteUtil
import com.aerofocus.util.TimeFormatters
import com.airbnb.lottie.compose.LottieAnimation
import com.airbnb.lottie.compose.LottieCompositionSpec
import com.airbnb.lottie.compose.LottieConstants
import com.airbnb.lottie.compose.rememberLottieComposition
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.Polyline
import com.google.maps.android.compose.rememberCameraPositionState

@Composable
fun InFlightScreen(
    onFinished: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: SessionViewModel = androidx.lifecycle.viewmodel.compose.viewModel()
) {
    val state by viewModel.sessionState.collectAsState()
    val context = LocalContext.current

    val start = state.fromCity?.let { cityName -> lookupLatLng(cityName) }
    val end = state.toCity?.let { cityName -> lookupLatLng(cityName) }
    val route = RouteUtil.buildRoute(start, end)
    val planePosition = RouteUtil.positionAlongRoute(route, state.progress)

    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(start ?: LatLng(0.0, 0.0), 3.5f)
    }

    LaunchedEffect(start, end) {
        start?.let {
            cameraPositionState.position = CameraPosition.fromLatLngZoom(it, 3.5f)
        }
    }

    LaunchedEffect(state.status) {
        if (state.status == SessionStatus.Completed || state.status == SessionStatus.Ended) {
            onFinished()
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        GoogleMap(
            modifier = Modifier.fillMaxSize(),
            cameraPositionState = cameraPositionState
        ) {
            start?.let { Marker(position = it, title = state.fromCity) }
            end?.let { Marker(position = it, title = state.toCity) }
            if (route.isNotEmpty()) {
                Polyline(points = route)
            }
            planePosition?.let { pos ->
                Marker(position = pos, title = "In Flight", icon = null)
            }
        }

        val composition by rememberLottieComposition(LottieCompositionSpec.Asset("clouds.json"))
        LottieAnimation(
            composition = composition,
            iterations = LottieConstants.IterateForever,
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer(alpha = 0.35f)
                .background(Color.Transparent),
            contentScale = ContentScale.Crop,
            speed = 0.5f
        )

        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Card(
                colors = CardDefaults.cardColors(containerColor = CloudWhite.copy(alpha = 0.9f)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "${state.fromCity ?: ""} → ${state.toCity ?: ""}",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(Modifier.height(8.dp))
                    Text("Remaining: ${TimeFormatters.formatDuration(state.remainingMillis)}")
                    Text("Progress: ${(state.progress * 100).toInt()}%")
                }
            }

            RowButtons(
                status = state.status,
                onPause = { SessionService.pause(context) },
                onResume = { SessionService.resume(context) },
                onEnd = { SessionService.end(context) }
            )
        }
    }
}

@Composable
private fun RowButtons(
    status: SessionStatus,
    onPause: () -> Unit,
    onResume: () -> Unit,
    onEnd: () -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Button(
            onClick = { if (status == SessionStatus.Running) onPause() else onResume() },
            modifier = Modifier.fillMaxWidth()
        ) {
            if (status == SessionStatus.Running) {
                Icon(Icons.Rounded.Pause, contentDescription = null)
                Spacer(Modifier.width(8.dp))
                Text("Pause")
            } else {
                Icon(Icons.Rounded.PlayArrow, contentDescription = null)
                Spacer(Modifier.width(8.dp))
                Text("Resume")
            }
        }
        Button(onClick = onEnd, modifier = Modifier.fillMaxWidth()) {
            Icon(Icons.Rounded.Flag, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("End Flight")
        }
    }
}

private fun lookupLatLng(displayName: String): LatLng? {
    val parts = displayName.split(", ")
    val cityName = parts.firstOrNull() ?: return null
    return com.aerofocus.util.CityData.cities.firstOrNull { it.name == cityName }?.let {
        LatLng(it.latitude, it.longitude)
    }
}
