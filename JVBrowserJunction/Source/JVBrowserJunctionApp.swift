//
//  JVBrowserJunctionApp.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

@main
struct JVBrowserJunctionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraView()
        } label: {
            MenuBarExtraLabelView()
        }

        Window("JV Browser Junction", id: K.WindowId.Settings) {
            SettingsWindowView()
        }
        .defaultSize(width: 900, height: 700)
        .windowResizability(.contentSize)
        .restorationDisabled()
        .launchSuppressed()
    }
}

extension Scene {
    fileprivate func restorationDisabled() -> some Scene {
        if #available(macOS 15.0, *) {
            return restorationBehavior(.disabled)
        } else {
            return self
        }
    }

    /// The app starts when a link is clicked, so the settings window must not open by itself.
    /// macOS 14 has no scene option for this; `AppDelegate` closes the window there instead.
    fileprivate func launchSuppressed() -> some Scene {
        if #available(macOS 15.0, *) {
            return defaultLaunchBehavior(.suppressed)
        } else {
            return self
        }
    }
}
