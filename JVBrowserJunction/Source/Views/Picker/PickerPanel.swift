//
//  PickerPanel.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit

/// Borderless, transparent panel that takes keyboard focus without activating the app, so the
/// app the link was clicked in stays frontmost behind it. SwiftUI has no window style for this.
final class PickerPanel: NSPanel {
    var onDismiss: (() -> Void)?

    init(content: NSView) {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        contentView = content
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .floating
        isFloatingPanel = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    override var canBecomeKey: Bool { true }

    /// Clicking anywhere outside the panel dismisses it.
    override func resignKey() {
        super.resignKey()
        onDismiss?()
    }
}
