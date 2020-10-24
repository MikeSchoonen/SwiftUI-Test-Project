//
//  SettingsViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 09/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import UIKit
import Combine
import Resolver

class SettingsViewModel: ObservableObject {
    @Injected var authenticationService: AuthenticationService
    @Published var themeColor: Color {
        didSet {
            UserDefaults.standard.set(themeColor.rawValue, forKey: "themeColor")
        }
    }
    @Published var userID = ""
    var appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let colorValue = UserDefaults.standard.string(forKey: "themeColor") ?? "Blue"
        themeColor = Color(rawValue: colorValue) ?? Color.blue
        
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userID, on: self)
            .store(in: &cancellables)
    }
    
    func reset() {
        themeColor = .blue
    }
    
    func signOut() {
        authenticationService.signOut()
    }
    
    enum Color: String, CaseIterable, Identifiable {
        case red = "Red"
        case green = "Green"
        case blue = "Blue"
        case indigo = "Indigo"
        case orange = "Orange"
        case pink = "Pink"
        case purple = "Purple"
        case teal = "Teal"
        case yellow = "Yellow"
        
        var id: String { self.rawValue }
        var displayName: String { self.rawValue }
        var systemColor: UIColor {
            switch self {
            case .red:
                return .systemRed
            case .green:
                return .systemGreen
            case .blue:
                return .systemBlue
            case .indigo:
                return .systemIndigo
            case .orange:
                return .systemOrange
            case .pink:
                return .systemPink
            case .purple:
                return .systemPurple
            case .teal:
                return .systemTeal
            case .yellow:
                return .systemYellow
            }
        }
    }
}
