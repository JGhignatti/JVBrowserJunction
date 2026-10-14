//
//  PickerHeaderView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

struct PickerHeaderView: View {
    let request: LinkRequest
    let index: Int
    let total: Int
    let onCopy: () -> Void

    private let sourceIconDimension: CGFloat = 30

    var body: some View {
        HStack(spacing: 10) {
            if let icon = request.sourceIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: sourceIconDimension, height: sourceIconDimension)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(request.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let detail = request.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                if let source = request.sourceName {
                    Text("from \(source)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .help(request.url.absoluteString)

            Spacer(minLength: 8)

            if total > 1 {
                Text("\(index) of \(total)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
                    .accessibilityLabel("Link \(index) of \(total)")
            }

            PickerCopyButton(action: onCopy)
        }
    }
}

#Preview {
    PickerHeaderView(
        request: .init(
            url: URL(string: "https://github.com/JGhignatti/JVWindowManager?tab=readme")!,
            sourceName: "Slack",
            sourceIcon: NSWorkspace.shared.icon(forFile: "/System/Applications/Mail.app")
        ),
        index: 1,
        total: 3,
        onCopy: {}
    )
    .frame(width: 380)
    .padding()
}
