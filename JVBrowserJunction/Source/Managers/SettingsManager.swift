//
//  SettingsManager.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit
import SwiftUI

/// Lets code outside a SwiftUI scene (the picker panel) open the Settings window.
@MainActor
final class SettingsManager {
    static let shared = SettingsManager()

    /// SwiftUI only hands out `openWindow` through the environment of a view inside a scene,
    /// so the menu bar label registers it here when the app starts.
    private var openWindow: OpenWindowAction?

    private init() {}

    func register(_ action: OpenWindowAction) {
        openWindow = action
    }

    func open() {
        // A menu bar only app cannot bring a window forward until it has a Dock presence.
        NSApp.setActivationPolicy(.regular)
        openWindow?(id: K.WindowId.Settings)
        NSApp.activate()
    }
}
