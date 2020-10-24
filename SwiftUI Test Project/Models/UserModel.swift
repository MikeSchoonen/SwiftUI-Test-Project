//
//  UserModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 26/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserModel: Codable {
    let userID: String
    let isAnonymous: Bool
    let email: String?
}
