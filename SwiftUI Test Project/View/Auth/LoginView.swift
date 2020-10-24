//
//  LoginView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 31/08/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.title)
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            SecureField("Password", text: $password)
                .autocapitalization(.none)
                .textContentType(.password)
            Button("Login") {
                
            }
            Divider()
            NavigationLink(destination: CreateAccountView()) {
                Text("Don't have an account?").foregroundColor(.gray)
                Text("Create an account")
            }.font(.footnote)
            Spacer()
        }.padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
