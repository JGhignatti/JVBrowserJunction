//
//  GeneralView.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import Defaults
import LaunchAtLogin
import SwiftUI

struct GeneralView: View {
    @Default(.pickerPosition) private var pickerPosition: PickerPosition

    private var defaultBrowserManager = DefaultBrowserManager.shared

    var body: some View {
        Form {
            if !defaultBrowserManager.isDefault {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Not the default browser")
                                .font(.headline)

                            Text(
                                "JV Browser Junction only sees the links you click while it is the default browser."
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("Set as Default…") {
                            defaultBrowserManager.requestDefault()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                LaunchAtLogin.Toggle("Launch at login")

                if defaultBrowserManager.isDefault {
                    LabeledContent("Default browser") {
                        Label("JV Browser Junction", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Picker("Show the picker", selection: $pickerPosition) {
                    ForEach(PickerPosition.allCases) { position in
                        Text(position.title).tag(position)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .navigationSubtitle("Startup and picker")
        .toolbarPlaceholder()
        .onAppear {
            defaultBrowserManager.refresh()
        }
    }
}

#Preview {
    GeneralView()
}
