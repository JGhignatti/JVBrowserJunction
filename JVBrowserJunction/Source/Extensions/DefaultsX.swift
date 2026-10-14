//
//  DefaultsX.swift
//  JVBrowserJunction
//
//  Created by João Ghignatti on 13/10/26.
//

import Defaults
import Foundation

extension Defaults.Keys {
    static let browserPreferences = Defaults.Key<[BrowserPreference]>(
        "_browserPreferences",
        default: []
    )

    static let pickerPosition = Defaults.Key<PickerPosition>(
        "_pickerPosition",
        default: .cursor
    )
}
