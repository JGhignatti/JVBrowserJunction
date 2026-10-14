//
//  PickerPosition.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import Defaults

/// Where the picker appears when a link is clicked.
enum PickerPosition: String, CaseIterable, Identifiable, Codable, Sendable, Defaults.Serializable {
    case cursor
    case screenCenter

    var id: Self { self }

    var title: String {
        switch self {
        case .cursor: "At the cursor"
        case .screenCenter: "Center of the screen"
        }
    }
}
