//
//  JunctionGlassModifier.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

/// Liquid Glass on macOS 26 and later; a behind-window blur with a hairline edge on 14 and 15.
struct JunctionGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

            content
                .background(BehindWindowBlur().clipShape(shape))
                .overlay(shape.strokeBorder(.white.opacity(0.18)))
                .shadow(color: .black.opacity(0.28), radius: 18, y: 8)
        }
    }
}

/// SwiftUI materials only blur content inside the window, which is empty in the picker panel,
/// so the pre-26 fallback needs AppKit's behind-window blending.
private struct BehindWindowBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
