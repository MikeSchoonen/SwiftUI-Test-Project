//
//  ListModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 24/08/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListModel: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var userID: String?
    var name: String
    var symbol: String = "questionmark.circle"
    var favorite: [String] = []
    @ServerTimestamp var createdTime: Timestamp?
    
    static func placeholder() -> ListModel {
        ListModel(name: "")
    }
}
