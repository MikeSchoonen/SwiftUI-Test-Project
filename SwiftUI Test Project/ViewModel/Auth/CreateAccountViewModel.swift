//
//  CreateAccountViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 23/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Resolver

class CreateAccountViewModel: ObservableObject {
    @LazyInjected var authenticationService: AuthenticationService
    
    @Published var email = ""
    @Published var password = ""
    @Published var repeatPassword = ""
    @Published var signedUp = false
    
    var passwordIsValid: Bool {
        password.count >= 8
    }
    
    var passwordsMatch: Bool {
        !password.isEmpty && !repeatPassword.isEmpty && password == repeatPassword
    }
    
    var formIsValid: Bool {
        passwordIsValid && passwordsMatch
    }
    
    func signUp(completion: @escaping (String?) -> Void) {
        authenticationService.signUp(with: email, password: password) { result in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error.description)
            }
        }
    }
    
}
