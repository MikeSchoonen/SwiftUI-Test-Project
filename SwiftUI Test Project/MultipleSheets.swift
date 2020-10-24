//
//  MultipleSheets.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 09/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation

enum ListViewSheet: Int, Identifiable {
    var id: Int { rawValue }
    case add, edit, settings
}

enum ActiveSheet: Int, Identifiable {
    var id: Int { rawValue }
    case add, settings
}

enum SettingsSheet: Int, Identifiable {
    var id: Int { rawValue }
    case createAccount, signIn, mail
}
