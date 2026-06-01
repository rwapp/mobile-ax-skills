// Before.kt
//
// A selectable list of devices. The user taps a device to select it; the chosen row shows a
// checkmark. Visually complete, with no accessibility treatment yet — this is the starting point
// the skill runs against.
//
// (Deliberately unannotated: it carries only the cues a developer would really write, so an
// agent has to work out each image's meaning from context — exactly as it would in a real
// codebase. The intended treatments and reasoning live in expected-experience.md.)
//
// Note the careless `contentDescription`s below — the resource/role names, not meanings. Compose
// forces you to pass *something*, and "satisfy the compiler" is exactly the trap.

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Circle
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image

data class Device(val id: String, val name: String, val isOnline: Boolean, val isPro: Boolean)

@Composable
fun DeviceList(devices: List<Device>) {
    var selectedId by remember { mutableStateOf<String?>(null) }
    LazyColumn {
        items(devices) { device ->
            DeviceRow(
                device = device,
                isSelected = device.id == selectedId,
                modifier = Modifier.clickable { selectedId = device.id },
            )
        }
    }
}

@Composable
fun DeviceRow(device: Device, isSelected: Boolean, modifier: Modifier = Modifier) {
    Row(modifier) {
        Icon(
            imageVector = Icons.Filled.AutoAwesome,
            contentDescription = "AutoAwesome",
        )
        Icon(
            imageVector = Icons.Filled.Circle,
            tint = if (device.isOnline) Color.Green else Color.Gray,
            contentDescription = "Circle",
        )
        Text(device.name)
        if (device.isPro) {
            Image(
                painter = painterResource(R.drawable.pro_badge),
                contentDescription = "pro_badge",
            )
        }
        Spacer(Modifier.weight(1f))
        if (isSelected) {
            Icon(
                imageVector = Icons.Filled.Check,
                contentDescription = "Check",
            )
        }
    }
}
