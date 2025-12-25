package com.aerofocus

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.aerofocus.ui.navigation.NavRoutes
import com.aerofocus.ui.screens.booking.FlightBookingScreen
import com.aerofocus.ui.screens.history.HistoryScreen
import com.aerofocus.ui.screens.inflight.InFlightScreen
import com.aerofocus.ui.screens.summary.SummaryScreen
import com.aerofocus.ui.theme.AeroFocusTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AeroFocusTheme {
                AeroFocusApp()
            }
        }
    }
}

@Composable
fun AeroFocusApp(navController: NavHostController = rememberNavController()) {
    Scaffold { padding ->
        NavHost(
            navController = navController,
            startDestination = NavRoutes.Booking,
            modifier = Modifier.padding(padding)
        ) {
            composable(NavRoutes.Booking) {
                FlightBookingScreen(onStart = { navController.navigate(NavRoutes.InFlight) })
            }
            composable(NavRoutes.InFlight) {
                InFlightScreen(
                    onFinished = { navController.navigate(NavRoutes.Summary) }
                )
            }
            composable(NavRoutes.Summary) {
                SummaryScreen(onDone = { navController.navigate(NavRoutes.History) })
            }
            composable(NavRoutes.History) {
                HistoryScreen()
            }
        }
    }
}
