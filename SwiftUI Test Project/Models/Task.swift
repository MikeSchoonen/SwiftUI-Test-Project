//
//  Task.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 24/08/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Task: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var userID: String?
    var listID: String
    var name: String
    var finished: Bool
    @ServerTimestamp var createdTime: Timestamp?
    
    static func placeholder() -> Task {
        Task(listID: "", name: "", finished: false)
    }
}
