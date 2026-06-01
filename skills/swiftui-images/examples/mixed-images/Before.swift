// Before.swift
//
// A selectable list of devices. The user taps a device to select it; the chosen row shows a
// checkmark. Visually complete, with no accessibility treatment yet — this is the starting point
// the skill runs against.
//
// (Deliberately unannotated: it carries only the cues a developer would really write, so an
// agent has to work out each image's meaning from context — exactly as it would in a real
// codebase. The intended treatments and reasoning live in expected-experience.md.)

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
                DeviceRow(device: device, isSelected: device.id == selectedID)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedID = device.id }
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")

            Image(systemName: "circle.fill")
                .foregroundStyle(device.isOnline ? .green : .gray)

            Text(device.name)

            if device.isPro {
                Image("proBadge")
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
}
