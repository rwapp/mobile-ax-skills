// After.swift
//
// The same selectable device list with each image given the treatment its meaning requires.
// The four images resolve to four different decisions — that's the point of this fixture:
//
//   1. sparkles      -> .accessibilityHidden(true)            (decorative)
//   2. status dot    -> .accessibilityLabel(status in words)  (meaningful — sole status cue)
//   3. proBadge      -> .accessibilityLabel("PRO")            (image of text)
//   4. checkmark     -> hidden; selection expressed as .isSelected on the ROW, which is the
//                       control the user actually picks. The list gives the trait a real parent.
//
// Intended result: a screen reader user moves through the list and hears one coherent
// announcement per row, e.g. "Living Room Speaker, Online, PRO, selected, button" for the chosen
// device and the same without "selected" for the others — the decorative sparkle is skipped, and
// no row announces a stray "checkmark".

import SwiftUI

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let isOnline: Bool
    let isPro: Bool
}

struct DeviceList: View {
    let devices: [Device]
    @State private var selectedID: Device.ID?

    var body: some View {
        List {
            ForEach(devices) { device in
                DeviceRow(device: device, isSelected: device.id == selectedID) {
                    selectedID = device.id
                }
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .accessibilityHidden(true)                       // 1. decorative

                Image(systemName: "circle.fill")
                    .foregroundStyle(device.isOnline ? .green : .gray)
                    .accessibilityLabel(device.isOnline ? "Online" : "Offline")  // 2. status in words

                Text(device.name)

                if device.isPro {
                    Image("proBadge")
                        .accessibilityLabel("PRO")                   // 3. the text in the image
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)                   // 4. visual only
                }
            }
        }
        // The row is the control the user selects. Combine its children into one announcement,
        // and express selection here with the trait — never as a stray "checkmark".
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
