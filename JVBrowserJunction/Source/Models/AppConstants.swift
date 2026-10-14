//
//  AppConstants.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import CoreGraphics

enum K {
    enum WindowId {
        static let Settings = "--jvbj_window-id_settings"
    }

    enum Picker {
        /// Browsers per row before the picker wraps onto another row.
        static let maxColumns = 6
        /// The header needs some room even when only one or two browsers are shown.
        static let minColumns = 3
        static let itemWidth: CGFloat = 92
        static let itemSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 28
        /// Transparent margin around the glass so its shadow is not clipped by the panel edge.
        static let outerPadding: CGFloat = 28
    }
}
