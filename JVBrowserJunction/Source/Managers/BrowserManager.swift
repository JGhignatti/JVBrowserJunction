//
//  BrowserManager.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit
import Defaults
import Observation
import UniformTypeIdentifiers

@MainActor
@Observable
final class BrowserManager {
    static let shared = BrowserManager()

    /// Every browser Launch Services knows about, in no particular order.
    /// The user's order and visibility live in `Defaults[.browserPreferences]`.
    private(set) var installed: [Browser] = []

    private static let probeURL = URL(string: "https://example.com")!

    private init() {
        refresh()
    }

    /// Re-reads the installed browsers and records any new ones in the saved preferences.
    /// Cheap enough to call every time the picker or the settings list is shown.
    func refresh() {
        installed = Self.discover()

        let saved = Defaults[.browserPreferences]
        let merged = BrowserPreference.merging(saved, withInstalled: installed.map(\.bundleID))
        if merged != saved {
            Defaults[.browserPreferences] = merged
        }
    }

    func browser(for bundleID: String) -> Browser? {
        installed.first { $0.bundleID == bundleID }
    }

    /// The browsers the picker should offer: installed, not hidden, in the user's order.
    var pickerBrowsers: [Browser] {
        Defaults[.browserPreferences]
            .filter(\.isVisible)
            .compactMap { browser(for: $0.bundleID) }
    }

    func setVisible(_ isVisible: Bool, for bundleID: String) {
        guard let index = Defaults[.browserPreferences].firstIndex(where: { $0.bundleID == bundleID }) else {
            return
        }
        Defaults[.browserPreferences][index].isVisible = isVisible
    }

    /// Saves a new order for the installed browsers, as shown in the settings list.
    func reorder(_ installedOrder: [BrowserPreference]) {
        Defaults[.browserPreferences] = BrowserPreference.reordering(
            Defaults[.browserPreferences],
            installedOrder: installedOrder
        )
    }

    /// Opens the URL in a specific app, bypassing the default handler (so it never loops back here).
    func open(_ url: URL, in browser: Browser, inBackground: Bool) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = !inBackground

        let name = browser.name
        NSWorkspace.shared.open([url], withApplicationAt: browser.url, configuration: configuration) { _, error in
            if let error {
                NSLog("Failed to open %@ in %@: %@", url.absoluteString, name, error.localizedDescription)
            }
        }
    }

    /// Apps registered for both https and HTML documents, excluding this app.
    /// Requiring HTML drops apps that only claim https for their own deep links.
    private static func discover() -> [Browser] {
        let workspace = NSWorkspace.shared
        let htmlHandlers = Set(workspace.urlsForApplications(toOpen: UTType.html).compactMap(bundleID))
        var seen: Set<String> = []

        return workspace.urlsForApplications(toOpen: probeURL).compactMap { appURL in
            guard
                let id = bundleID(appURL),
                id != Bundle.main.bundleIdentifier,
                htmlHandlers.contains(id),
                seen.insert(id).inserted
            else {
                return nil
            }

            return Browser(
                bundleID: id,
                name: FileManager.default.displayName(atPath: appURL.path),
                url: appURL,
                icon: workspace.icon(forFile: appURL.path),
                isRunning: !NSRunningApplication.runningApplications(withBundleIdentifier: id).isEmpty
            )
        }
    }

    private static func bundleID(_ appURL: URL) -> String? {
        Bundle(url: appURL)?.bundleIdentifier
    }
}
