//
//  PickerModel.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import Observation

/// State of the picker currently on screen.
@MainActor
@Observable
final class PickerModel {
    let request: LinkRequest
    let browsers: [Browser]
    /// Position of this link among the links that arrived together, starting at 1.
    let index: Int

    var total: Int
    var selection = 0
    /// Drives the appear and disappear animation.
    var isPresented = false

    init(request: LinkRequest, browsers: [Browser], index: Int, total: Int) {
        self.request = request
        self.browsers = browsers
        self.index = index
        self.total = total
    }

    var columns: Int {
        min(max(browsers.count, K.Picker.minColumns), K.Picker.maxColumns)
    }

    var selectedBrowser: Browser? {
        browsers.indices.contains(selection) ? browsers[selection] : nil
    }

    /// Moves the selection along the row, wrapping at either end.
    func moveSelection(by offset: Int) {
        guard !browsers.isEmpty else {
            return
        }
        selection = (selection + offset + browsers.count) % browsers.count
    }

    /// Moves the selection to the row above or below, staying put when there is none.
    func moveSelection(byRows rows: Int) {
        let target = selection + rows * columns
        if browsers.indices.contains(target) {
            selection = target
        }
    }
}
