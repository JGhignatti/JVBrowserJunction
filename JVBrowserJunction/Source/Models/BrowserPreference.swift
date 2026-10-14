//
//  BrowserPreference.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import Defaults

/// The user's choice for one browser. The position in the saved array is the display order.
struct BrowserPreference: Codable, Hashable, Identifiable, Sendable, Defaults.Serializable {
    let bundleID: String
    var isVisible: Bool

    var id: String { bundleID }

    /// Keeps every saved entry where it is and appends browsers seen for the first time, visible.
    /// Entries for browsers that are no longer installed stay, so a reinstall restores their
    /// position and visibility.
    static func merging(_ saved: [BrowserPreference], withInstalled installed: [String]) -> [BrowserPreference] {
        let known = Set(saved.map(\.bundleID))
        return saved + installed
            .filter { !known.contains($0) }
            .map { BrowserPreference(bundleID: $0, isVisible: true) }
    }

    /// Applies a reorder of the installed entries without disturbing the slots of uninstalled ones.
    static func reordering(_ saved: [BrowserPreference], installedOrder: [BrowserPreference]) -> [BrowserPreference] {
        let installed = Set(installedOrder.map(\.bundleID))
        var next = installedOrder.makeIterator()
        return saved.map { installed.contains($0.bundleID) ? (next.next() ?? $0) : $0 }
    }
}
