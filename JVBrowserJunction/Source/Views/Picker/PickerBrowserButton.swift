//
//  PickerBrowserButton.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

struct PickerBrowserButton: View {
    let browser: Browser
    /// The number key that picks this browser, when it has one.
    let shortcut: Int?
    let isSelected: Bool
    let selectionNamespace: Namespace.ID
    let onHover: () -> Void
    let action: () -> Void

    private let iconDimension: CGFloat = 56
    private let cornerRadius: CGFloat = 18

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(nsImage: browser.icon)
                    .resizable()
                    .frame(width: iconDimension, height: iconDimension)

                // Same cue as the Dock: a dot under apps that are already open.
                Circle()
                    .fill(.secondary)
                    .frame(width: 4, height: 4)
                    .opacity(browser.isRunning ? 1 : 0)

                Text(browser.name)
                    .font(.caption)
                    .lineLimit(1)

                Text(shortcut.map(String.init) ?? " ")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 4)
            .frame(width: K.Picker.itemWidth)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    // One highlight shared by all buttons, so it slides instead of blinking.
                    PickerSelectionHighlight(cornerRadius: cornerRadius)
                        .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            if isHovering {
                onHover()
            }
        }
        .help(browser.name)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var label = "Open in \(browser.name)"
        if let shortcut {
            label += ", \(shortcut)"
        }
        if browser.isRunning {
            label += ", running"
        }
        return label
    }
}

private struct PickerSelectionHighlight: View {
    let cornerRadius: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if #available(macOS 26, *) {
            // Tinted so the highlight stays readable on top of the panel's own glass.
            Color.clear
                .glassEffect(.regular.tint(.primary.opacity(0.12)).interactive(), in: shape)
        } else {
            shape.fill(.primary.opacity(0.12))
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace

    PickerBrowserButton(
        browser: .init(
            bundleID: "com.apple.Safari",
            name: "Safari",
            url: URL(fileURLWithPath: "/Applications/Safari.app"),
            icon: NSWorkspace.shared.icon(forFile: "/Applications/Safari.app"),
            isRunning: true
        ),
        shortcut: 1,
        isSelected: true,
        selectionNamespace: namespace,
        onHover: {},
        action: {}
    )
    .padding()
}
