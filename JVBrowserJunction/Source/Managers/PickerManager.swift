//
//  PickerManager.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import AppKit
import Defaults
import SwiftUI

/// Shows one picker at a time; links that arrive while one is open wait their turn.
@MainActor
final class PickerManager {
    static let shared = PickerManager()

    private var queue: [LinkRequest] = []
    private var panel: PickerPanel?
    private var model: PickerModel?

    /// Counters for the "2 of 3" label; reset once the queue has drained.
    private var shownCount = 0
    private var totalCount = 0

    private static let dismissDuration: Duration = .milliseconds(140)

    private init() {}

    func enqueue(_ request: LinkRequest) {
        queue.append(request)
        totalCount += 1
        model?.total = totalCount

        if panel == nil {
            showNext()
        }
    }

    private func showNext() {
        guard !queue.isEmpty else {
            shownCount = 0
            totalCount = 0
            return
        }

        BrowserManager.shared.refresh()
        DefaultBrowserManager.shared.refresh()

        shownCount += 1
        let model = PickerModel(
            request: queue.removeFirst(),
            browsers: BrowserManager.shared.pickerBrowsers,
            index: shownCount,
            total: totalCount
        )

        let hosting = NSHostingView(
            rootView: PickerView(
                model: model,
                onPick: { [weak self] browser, inBackground in self?.pick(browser, inBackground: inBackground) },
                onCopy: { [weak self] in self?.copyLink() },
                onOpenSettings: { [weak self] in self?.openSettings() },
                onCancel: { [weak self] in self?.dismiss() }
            )
        )

        let panel = PickerPanel(content: hosting)
        panel.onDismiss = { [weak self] in self?.dismiss() }
        panel.setFrame(Self.frame(for: hosting.fittingSize), display: true)

        self.model = model
        self.panel = panel
        panel.makeKeyAndOrderFront(nil)
    }

    private func pick(_ browser: Browser, inBackground: Bool) {
        guard let url = model?.request.url else {
            return
        }

        dismiss()
        BrowserManager.shared.open(url, in: browser, inBackground: inBackground)
    }

    private func copyLink() {
        guard let url = model?.request.url else {
            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
        dismiss()
    }

    private func openSettings() {
        dismiss()
        SettingsManager.shared.open()
    }

    /// Closes the current picker and moves on to the next queued link, if any.
    private func dismiss() {
        guard let panel, let model else {
            return
        }

        self.panel = nil
        self.model = nil
        panel.onDismiss = nil

        if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            panel.orderOut(nil)
        } else {
            model.isPresented = false
            Task {
                try? await Task.sleep(for: Self.dismissDuration)
                panel.orderOut(nil)
            }
        }

        showNext()
    }

    /// Places the panel per the user's setting, kept inside the visible area of the cursor's screen.
    private static func frame(for size: NSSize) -> NSRect {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        let visible = screen?.visibleFrame

        var origin: NSPoint
        switch Defaults[.pickerPosition] {
        case .cursor:
            // Horizontally centered on the cursor, with the top of the glass just above it.
            origin = NSPoint(
                x: mouse.x - size.width / 2,
                y: mouse.y - size.height + K.Picker.outerPadding
            )
        case .screenCenter:
            let area = visible ?? NSRect(origin: mouse, size: .zero)
            origin = NSPoint(
                x: area.midX - size.width / 2,
                y: area.midY - size.height / 2
            )
        }

        if let visible {
            origin.x = min(max(origin.x, visible.minX), visible.maxX - size.width)
            origin.y = min(max(origin.y, visible.minY), visible.maxY - size.height)
        }

        return NSRect(origin: origin, size: size)
    }
}
