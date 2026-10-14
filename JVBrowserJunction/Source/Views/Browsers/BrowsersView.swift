//
//  BrowsersView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import Defaults
import SwiftUI

struct BrowsersView: View {
    @Default(.browserPreferences) private var preferences: [BrowserPreference]

    private var browserManager = BrowserManager.shared

    /// Saved preferences can include browsers that have since been uninstalled; those are not listed.
    private var installedPreferences: [BrowserPreference] {
        preferences.filter { browserManager.browser(for: $0.bundleID) != nil }
    }

    var body: some View {
        List {
            ForEach(installedPreferences) { preference in
                if let browser = browserManager.browser(for: preference.bundleID) {
                    BrowserRowView(
                        browser: browser,
                        isVisible: Binding(
                            get: { preference.isVisible },
                            set: { browserManager.setVisible($0, for: preference.bundleID) }
                        )
                    )
                }
            }
            .onMove { indices, newOffset in
                var copy = installedPreferences
                copy.move(fromOffsets: indices, toOffset: newOffset)

                browserManager.reorder(copy)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .navigationTitle("Browsers")
        .navigationSubtitle("Order and visibility")
        .toolbarPlaceholder()
        .overlay {
            if installedPreferences.isEmpty {
                ContentUnavailableView(
                    "No Browsers Found",
                    systemImage: "globe",
                    description: Text("Install a web browser and it will show up here.")
                )
            }
        }
        .onAppear {
            browserManager.refresh()
        }
    }
}

#Preview {
    BrowsersView()
}
