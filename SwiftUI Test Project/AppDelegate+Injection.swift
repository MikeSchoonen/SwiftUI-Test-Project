//
//  AppDelegate+Injection.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 02/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { FirestoreListRepository() as ListRepository }.scope(application)
        register { AuthenticationService() }.scope(application)
        register { FirestoreTaskRepository() as TaskRepository }.scope(application)
    }
}
