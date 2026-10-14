//
//  LinkRequest.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit

/// A link (or HTML file) waiting for the user to choose a browser.
struct LinkRequest {
    let url: URL
    let sourceName: String?
    let sourceIcon: NSImage?

    /// The part worth reading first: the site, or the file name.
    var title: String {
        url.isFileURL ? url.lastPathComponent : (url.host() ?? url.absoluteString)
    }

    /// The rest of the address, or nil when there is nothing beyond the title.
    var detail: String? {
        if url.isFileURL {
            return (url.deletingLastPathComponent().path as NSString).abbreviatingWithTildeInPath
        }
        var rest = url.path(percentEncoded: false)
        if let query = url.query(percentEncoded: false) {
            rest += "?" + query
        }
        return rest.isEmpty || rest == "/" ? nil : rest
    }
}
