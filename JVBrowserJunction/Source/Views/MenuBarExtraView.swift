//
//  MenuBarExtraView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

struct MenuBarExtraView: View {
    private var defaultBrowserManager = DefaultBrowserManager.shared

    var body: some View {
        if !defaultBrowserManager.isDefault {
            Button("Set as Default Browser…") {
                defaultBrowserManager.requestDefault()
            }

            Divider()
        }

        Button("Settings…") {
            SettingsManager.shared.open()
        }
        .keyboardShortcut(",")

        Divider()

        Button("Quit JV Browser Junction") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

#Preview {
    MenuBarExtraView()
}
