//
//  PickerCopyButton.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

/// The system's hover highlight and `.help` tooltip only work in the active app, and the picker
/// deliberately never activates this one, so the button draws both itself.
struct PickerCopyButton: View {
    let action: () -> Void

    @State private var isHovering = false

    private let dimension: CGFloat = 26

    var body: some View {
        Button(action: action) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isHovering ? .primary : .secondary)
                .frame(width: dimension, height: dimension)
                .background(.primary.opacity(isHovering ? 0.12 : 0), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut("c", modifiers: .command)
        .onHover { isHovering = $0 }
        .overlay(alignment: .topTrailing) {
            if isHovering {
                Text("Copy Link  ⌘C")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .fixedSize()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.78), in: Capsule())
                    // Hangs just below the button without taking part in the header's layout.
                    .offset(y: dimension + 4)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .accessibilityLabel("Copy Link")
    }
}

#Preview {
    PickerCopyButton(action: {})
        .padding(40)
}
