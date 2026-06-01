// After.kt
//
// The same selectable device list with each image given the treatment its meaning requires.
// The four images resolve to four different decisions — that's the point of this fixture:
//
//   1. AutoAwesome   -> contentDescription = null                 (decorative)
//   2. status dot    -> contentDescription = status in words      (meaningful — sole status cue)
//   3. proBadge      -> contentDescription = "PRO"                (image of text)
//   4. checkmark     -> contentDescription = null; selection expressed on the ROW via
//                       Modifier.selectable(selected = …), which is the control the user picks.
//
// Intended result: a TalkBack user moves through the list and hears one announcement per row,
// e.g. "Living Room Speaker, Online, PRO, selected" for the chosen device and the same without
// "selected" for the others — the decorative flourish is skipped, and no row announces a stray
// "check" or "circle".

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
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
import androidx.compose.ui.semantics.Role
import androidx.compose.foundation.Image

data class Device(val id: String, val name: String, val isOnline: Boolean, val isPro: Boolean)

@Composable
fun DeviceList(devices: List<Device>) {
    var selectedId by remember { mutableStateOf<String?>(null) }
    LazyColumn(Modifier.selectableGroup()) {
        items(devices) { device ->
            DeviceRow(
                device = device,
                isSelected = device.id == selectedId,
                onSelect = { selectedId = device.id },
            )
        }
    }
}

@Composable
fun DeviceRow(device: Device, isSelected: Boolean, onSelect: () -> Unit) {
    // The row is the control the user selects. `selectable` sets the role, exposes the selected
    // state to TalkBack, and merges descendant semantics into one announcement.
    Row(
        Modifier.selectable(selected = isSelected, onClick = onSelect, role = Role.RadioButton)
    ) {
        Icon(
            imageVector = Icons.Filled.AutoAwesome,
            contentDescription = null,                                  // 1. decorative
        )
        Icon(
            imageVector = Icons.Filled.Circle,
            tint = if (device.isOnline) Color.Green else Color.Gray,
            contentDescription = if (device.isOnline) "Online" else "Offline",  // 2. status in words
        )
        Text(device.name)
        if (device.isPro) {
            Image(
                painter = painterResource(R.drawable.pro_badge),
                contentDescription = "PRO",                            // 3. the text in the image
            )
        }
        Spacer(Modifier.weight(1f))
        if (isSelected) {
            Icon(
                imageVector = Icons.Filled.Check,
                contentDescription = null,                             // 4. visual only; state is on the row
            )
        }
    }
}
