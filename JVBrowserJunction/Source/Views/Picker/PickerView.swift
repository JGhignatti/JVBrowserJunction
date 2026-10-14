//
//  PickerView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import SwiftUI

struct PickerView: View {
    let model: PickerModel
    /// Called with the chosen browser and whether Option was held, which opens it in the background.
    let onPick: (Browser, _ inBackground: Bool) -> Void
    let onCopy: () -> Void
    let onOpenSettings: () -> Void
    let onCancel: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isFocused: Bool
    @Namespace private var selectionNamespace

    private var contentWidth: CGFloat {
        CGFloat(model.columns) * K.Picker.itemWidth
            + CGFloat(model.columns - 1) * K.Picker.itemSpacing
    }

    /// Browser indices split into rows of at most `K.Picker.maxColumns`.
    private var rows: [Range<Int>] {
        stride(from: 0, to: model.browsers.count, by: model.columns).map {
            $0..<min($0 + model.columns, model.browsers.count)
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            PickerHeaderView(
                request: model.request,
                index: model.index,
                total: model.total,
                onCopy: onCopy
            )
            // Keeps the copy button's hover label above the browser icons below it.
            .zIndex(1)

            if model.browsers.isEmpty {
                emptyState
            } else {
                browserGrid

                Text("Hold ⌥ to open in the background")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: contentWidth)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .junctionGlass(cornerRadius: K.Picker.cornerRadius)
        .scaleEffect(model.isPresented ? 1 : 0.94)
        .opacity(model.isPresented ? 1 : 0)
        .animation(reduceMotion ? nil : .snappy(duration: 0.18), value: model.isPresented)
        .padding(K.Picker.outerPadding)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .onKeyPress(phases: .down, action: handleKeyPress)
        .onAppear {
            isFocused = true
            model.isPresented = true
        }
    }

    private var browserGrid: some View {
        VStack(spacing: K.Picker.itemSpacing) {
            ForEach(rows, id: \.lowerBound) { row in
                HStack(spacing: K.Picker.itemSpacing) {
                    ForEach(row, id: \.self) { index in
                        let browser = model.browsers[index]

                        PickerBrowserButton(
                            browser: browser,
                            shortcut: index < 9 ? index + 1 : nil,
                            isSelected: model.selection == index,
                            selectionNamespace: selectionNamespace,
                            onHover: { model.selection = index },
                            action: { onPick(browser, NSEvent.modifierFlags.contains(.option)) }
                        )
                    }
                }
            }
        }
        .animation(reduceMotion ? nil : .snappy(duration: 0.18), value: model.selection)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No browsers to show")
                .font(.callout)

            Text("Every installed browser is hidden, or none was found.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Open Settings…", action: onOpenSettings)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }

    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .escape:
            onCancel()
        case .return:
            guard let browser = model.selectedBrowser else {
                return .ignored
            }
            onPick(browser, press.modifiers.contains(.option))
        case .leftArrow:
            model.moveSelection(by: -1)
        case .rightArrow:
            model.moveSelection(by: 1)
        case .tab:
            model.moveSelection(by: press.modifiers.contains(.shift) ? -1 : 1)
        case .upArrow:
            model.moveSelection(byRows: -1)
        case .downArrow:
            model.moveSelection(byRows: 1)
        default:
            // Number keys pick directly; `characters` ignores Option, so ⌥1 still reads as 1.
            guard
                let digit = Int(press.characters),
                model.browsers.indices.contains(digit - 1)
            else {
                return .ignored
            }
            onPick(model.browsers[digit - 1], press.modifiers.contains(.option))
        }

        return .handled
    }
}

#Preview {
    PickerView(
        model: .init(
            request: .init(
                url: URL(string: "https://github.com/JGhignatti/JVWindowManager")!,
                sourceName: "Slack",
                sourceIcon: nil
            ),
            browsers: ["Safari", "Firefox"].map {
                .init(
                    bundleID: $0,
                    name: $0,
                    url: URL(fileURLWithPath: "/Applications/\($0).app"),
                    icon: NSWorkspace.shared.icon(forFile: "/Applications/\($0).app"),
                    isRunning: $0 == "Safari"
                )
            },
            index: 1,
            total: 2
        ),
        onPick: { _, _ in },
        onCopy: {},
        onOpenSettings: {},
        onCancel: {}
    )
}
