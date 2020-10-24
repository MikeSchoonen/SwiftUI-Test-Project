//
//  SettingsView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 09/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsViewModel
    
    @State private var selectedSheet: SettingsSheet? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("GENERAL")) {
                    Text("UserID: \(settings.userID)")
                    Picker("Theme color", selection: $settings.themeColor) {
                        ForEach(SettingsViewModel.Color.allCases) { color in
                            Text(color.displayName).tag(color)
                        }
                    }
                }
                Section(header: Text("ACCOUNT")) {
                    Button("Create account") {
                        selectedSheet = .createAccount
                    }
                    Button("Sign in") {
                        selectedSheet = .signIn
                    }
                    Button("Sign out") {
                        settings.signOut()
                    }
                }
                Section(header: Text("FEEDBACK")) {
                    Button("Suggest a feature") {
                        selectedSheet = .mail
                    }
                }
                Section {
                    Button("Reset all settings") {
                        self.settings.reset()
                    }
                }
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(settings.appVersion)
                    }
                }
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") { presentationMode.wrappedValue.dismiss() })
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .createAccount:
                    CreateAccountView().environmentObject(settings)
                case .signIn:
                    Text("SignIn")
                case .mail:
                    MailView()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView().navigationBarTitle(Text("Settings"), displayMode: .large)
        }
    }
}
