//
//  ViewX.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

extension View {
    func junctionGlass(cornerRadius: CGFloat) -> some View {
        self.modifier(JunctionGlassModifier(cornerRadius: cornerRadius))
    }

    /// Adds an invisible toolbar item so tabs without toolbar actions keep the
    /// same title bar height (and traffic-light position) as the ones with them.
    func toolbarPlaceholder() -> some View {
        toolbar {
            if #available(macOS 26, *) {
                ToolbarItem(placement: .primaryAction) {
                    ToolbarPlaceholderView()
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .primaryAction) {
                    ToolbarPlaceholderView()
                }
            }
        }
    }
}

private struct ToolbarPlaceholderView: View {
    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .accessibilityHidden(true)
    }
}
