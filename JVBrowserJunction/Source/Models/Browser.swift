//
//  Browser.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit

/// An installed app that can open web links.
struct Browser: Identifiable {
    let bundleID: String
    let name: String
    let url: URL
    let icon: NSImage
    let isRunning: Bool

    var id: String { bundleID }
}
