//
//  AuthenticationService.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 25/08/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class AuthenticationService: ObservableObject {
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        registerStateListener()
    }
    
    private func registerStateListener() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            print("DEBUG: Auth state changed")
            self.user = user
            
            guard let _ = user else {
                print("DEBUG: User isn't signed in")
                self.signIn()
                return
            }
        }
    }
    
    func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { authDataResult, error in
                guard let user = authDataResult?.user else { return }
                self.user = user
                self.storeUser(user)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Unable to sign out user")
        }
    }
    
    func signUp(with email: String, password: String, completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }
        guard isValidPassword(password) else {
            completion(.failure(.weakPassword))
            return
        }
        guard let user = Auth.auth().currentUser else {
            completion(.failure(.unknownError))
            return
        }
        
        let authCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.link(with: authCredential) { authResult, error in
            if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    completion(.failure(.operationNotAllowed))
                case .emailAlreadyInUse:
                    completion(.failure(.emailAlreadyInUse))
                case .invalidEmail:
                    completion(.failure(.invalidEmail))
                case .weakPassword:
                    completion(.failure(.weakPassword))
                default:
                    completion(.failure(.unknownError))
                }
            }
            
            guard let user = authResult?.user else {
                completion(.failure(.unknownError))
                return
            }
            
            self.user = user
            self.storeUser(user)
            completion(.success(()))
        }
    }
//    
//    func signIn(with email: String, password: String, completion: @escaping (Result<User, AuthenticationServiceError>) -> Void) {
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let error = error as? NSError {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .operationNotAllowed:
//                    completion(.failure(.operationNotAllowed))
//                case .userDisabled:
//                    completion(.failure(.userDisabled))
//                case .wrongPassword:
//                    completion(.failure(.wrongPassword))
//                case .invalidEmail:
//                    completion(.failure(.invalidEmail))
//                default:
//                    completion(.failure(.unknownError))
//                }
//            }
//            
//            guard let user = authResult?.user else {
//                completion(.failure(.unknownError))
//                return
//            }
//            
//            self.user = user
//            completion(.success(user))
//        }
//    }
//    
//    func sendPasswordReset(to email: String, completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            if let error = error as? NSError {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .userNotFound:
//                    completion(.failure(.userNotFound))
//                case .invalidEmail:
//                    completion(.failure(.invalidEmail))
//                case .invalidRecipientEmail:
//                    completion(.failure(.invalidRecipientEmail))
//                case .invalidSender:
//                    completion(.failure(.invalidSender))
//                case .invalidMessagePayload:
//                    completion(.failure(.invalidMessagePayload))
//                default:
//                    completion(.failure(.unknownError))
//                }
//            }
//            
//            completion(.success(()))
//        }
//    }
//    
//    func updatePassword(to password: String, completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
//        guard let user = Auth.auth().currentUser else {
//            completion(.failure(.unknownError))
//            return
//        }
//        user.updatePassword(to: password) { error in
//            if let error = error as? NSError {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .userDisabled:
//                    completion(.failure(.userDisabled))
//                case .weakPassword:
//                    completion(.failure(.weakPassword))
//                case .operationNotAllowed:
//                    completion(.failure(.operationNotAllowed))
//                case .requiresRecentLogin:
//                    completion(.failure(.requiresRecentLogin))
//                default:
//                    completion(.failure(.unknownError))
//                }
//            }
//            
//            completion(.success(()))
//        }
//    }
//    
//    func updateEmail(to email: String, completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
//        guard let user = Auth.auth().currentUser else {
//            completion(.failure(.unknownError))
//            return
//        }
//        user.updateEmail(to: email) { error in
//            if let error = error as? NSError {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .invalidRecipientEmail:
//                    completion(.failure(.invalidRecipientEmail))
//                case .invalidSender:
//                    completion(.failure(.invalidSender))
//                case .invalidMessagePayload:
//                    completion(.failure(.invalidMessagePayload))
//                case .emailAlreadyInUse:
//                    completion(.failure(.emailAlreadyInUse))
//                case .invalidEmail:
//                    completion(.failure(.invalidEmail))
//                case .requiresRecentLogin:
//                    completion(.failure(.requiresRecentLogin))
//                default:
//                    completion(.failure(.unknownError))
//                }
//            }
//            
//            completion(.success(()))
//        }
//    }
//    
//    func deleteAccount(completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
//        guard let user = Auth.auth().currentUser else {
//            completion(.failure(.unknownError))
//            return
//        }
//        user.delete { error in
//            if let error = error as? NSError {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .operationNotAllowed:
//                    completion(.failure(.operationNotAllowed))
//                case .requiresRecentLogin:
//                    completion(.failure(.requiresRecentLogin))
//                default:
//                    completion(.failure(.unknownError))
//                }
//            }
//            
//            completion(.success(()))
//        }
//    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 8
        return password.count >= minPasswordLength
    }
    
    private func storeUser(_ user: User) {
        let userModel = UserModel(userID: user.uid, isAnonymous: user.isAnonymous, email: user.email)
        do {
            try self.db.collection("users").document(userModel.userID).setData(from: userModel)
        } catch {
            print("DEBUG: Failed to save userdata.")
        }
    }
    
}

enum AuthenticationServiceError: Error {
    case unknownError, operationNotAllowed, emailAlreadyInUse, invalidEmail, weakPassword, userDisabled, wrongPassword, userNotFound, invalidRecipientEmail, invalidSender, invalidMessagePayload, requiresRecentLogin

    var description: String {
        switch self {
        case .unknownError:
            return "Something unexpected happend."
        case .operationNotAllowed:
            return "The given sign-in provider is disabled for this Firebase project."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .invalidEmail:
            return "The email address is badly formatted."
        case .weakPassword:
            return "The password must be 6 characters long or more."
        case .userDisabled:
            return "The user account has been disabled by an administrator."
        case .wrongPassword:
            return "The password is invalid or the user does not have a password."
        case .userNotFound:
            return "The given sign-in provider is disabled for this Firebase project."
        case .invalidRecipientEmail:
            return "Indicates an invalid recipient email was sent in the request."
        case .invalidSender:
            return "Indicates an invalid sender email is set in the console for this action."
        case .invalidMessagePayload:
            return "Indicates an invalid email template for sending update email."
        case .requiresRecentLogin:
            return "Updating a user’s password is a security sensitive operation that requires a recent login from the user."
        }
    }
}
