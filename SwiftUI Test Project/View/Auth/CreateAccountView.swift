//
//  CreateAccountView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 31/08/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsViewModel
    @ObservedObject var createAccountViewModel = CreateAccountViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Group {
                    Text("Email")
                    TextField("example@example.com", text: $createAccountViewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5)
                }
                Group {
                    Text("Password")
                    SecureField("Password", text: $createAccountViewModel.password)
                        .autocapitalization(.none)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5)
                }
                Group {
                    Text("Repeat password")
                    SecureField("Repeat password", text: $createAccountViewModel.repeatPassword)
                        .autocapitalization(.none)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5)
                        .padding(.bottom)
                }
                Button(action: {
                    createAccountViewModel.signUp { errorMessage in
                        if let errorMessage = errorMessage {
                            print(errorMessage)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    Text("Create")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(settings.themeColor.systemColor))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .disabled(!createAccountViewModel.formIsValid)
                })
                Text("An account allows to save and access notes across devices.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
            }.padding()
            .navigationBarTitle(Text("Create an account"), displayMode: .inline)
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateAccountView()
        }.sheet(isPresented: .constant(true), content: {
            CreateAccountView()
        })
    }
}
