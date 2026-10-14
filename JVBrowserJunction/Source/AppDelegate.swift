//
//  AppDelegate.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit
import Carbon.HIToolbox

/// Receives the links the system sends to the default browser. SwiftUI's `onOpenURL` needs a
/// window scene to deliver to, and this app has none on screen, so intake stays in AppKit.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Clicked http/https links arrive as a "get URL" Apple Event.
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURL(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // macOS 14 opens the settings window at launch; later versions suppress it in the scene.
        if #unavailable(macOS 15.0) {
            for window in NSApp.windows where window.identifier?.rawValue == K.WindowId.Settings {
                window.close()
            }
        }
    }

    /// HTML files opened with this app arrive here as file URLs.
    func application(_ application: NSApplication, open urls: [URL]) {
        let source = Self.sender(of: NSAppleEventManager.shared().currentAppleEvent)
        for url in urls {
            enqueue(url, from: source)
        }
    }

    @objc private func handleGetURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        guard
            let string = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
            let url = URL(string: string)
        else {
            return
        }

        enqueue(url, from: Self.sender(of: event))
    }

    private func enqueue(_ url: URL, from source: NSRunningApplication?) {
        PickerManager.shared.enqueue(
            LinkRequest(url: url, sourceName: source?.localizedName, sourceIcon: source?.icon)
        )
    }

    /// The Apple Event that delivered the link carries the PID of the app it was clicked in.
    private static func sender(of event: NSAppleEventDescriptor?) -> NSRunningApplication? {
        guard
            let pid = event?.attributeDescriptor(forKeyword: AEKeyword(keySenderPIDAttr))?.int32Value,
            pid != ProcessInfo.processInfo.processIdentifier
        else {
            return nil
        }

        return NSRunningApplication(processIdentifier: pid)
    }
}
