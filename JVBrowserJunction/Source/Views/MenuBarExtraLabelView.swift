//
//  MenuBarExtraLabelView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

struct MenuBarExtraLabelView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image("MenuBarIcon")
            .accessibilityLabel("JV Browser Junction")
            .onAppear {
                // This is the one view that always exists, so it lends its environment's
                // action to code that runs outside any scene.
                SettingsManager.shared.register(openWindow)
            }
    }
}

#Preview {
    MenuBarExtraLabelView()
}
