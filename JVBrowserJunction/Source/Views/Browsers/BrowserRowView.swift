//
//  BrowserRowView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

struct BrowserRowView: View {
    let browser: Browser
    @Binding var isVisible: Bool

    private let iconDimension: CGFloat = 32

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Image(nsImage: browser.icon)
                .resizable()
                .frame(width: iconDimension, height: iconDimension)
                .opacity(isVisible ? 1 : 0.5)

            Text(browser.name)
                .foregroundStyle(isVisible ? .primary : .secondary)

            Spacer()

            Toggle("Show \(browser.name) in the picker", isOn: $isVisible)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

#Preview {
    BrowserRowView(
        browser: .init(
            bundleID: "com.apple.Safari",
            name: "Safari",
            url: URL(fileURLWithPath: "/Applications/Safari.app"),
            icon: NSWorkspace.shared.icon(forFile: "/Applications/Safari.app"),
            isRunning: true
        ),
        isVisible: .constant(true)
    )
}
