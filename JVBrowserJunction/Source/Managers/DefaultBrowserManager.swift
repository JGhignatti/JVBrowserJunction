//
//  DefaultBrowserManager.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit
import Observation

@MainActor
@Observable
final class DefaultBrowserManager {
    static let shared = DefaultBrowserManager()

    private(set) var isDefault = false

    private static let probeURL = URL(string: "https://example.com")!

    private init() {
        refresh()

        // Launch Services posts nothing when the default browser changes. The change is always
        // made in another app (System Settings, or the system's confirmation dialog), so
        // re-checking whenever the frontmost app changes keeps the state current.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func refresh() {
        let current = NSWorkspace.shared.urlForApplication(toOpen: Self.probeURL)
        let isDefault = current.flatMap { Bundle(url: $0)?.bundleIdentifier } == Bundle.main.bundleIdentifier
        if isDefault != self.isDefault {
            self.isDefault = isDefault
        }
    }

    /// Asks the system to make this app the default browser. macOS always shows its own
    /// confirmation for http/https, and setting http carries https and HTML along with it.
    func requestDefault() {
        NSWorkspace.shared.setDefaultApplication(at: Bundle.main.bundleURL, toOpenURLsWithScheme: "http") { error in
            if let error {
                NSLog("Default browser request failed: %@", error.localizedDescription)
            }
        }

        // The confirmation belongs to another process and can open behind other windows.
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.coreservices.uiagent")
            .first?.activate()
    }
}
