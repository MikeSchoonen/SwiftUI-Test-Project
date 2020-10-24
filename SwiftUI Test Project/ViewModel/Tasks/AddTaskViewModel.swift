//
//  AddTaskViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 03/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class AddTaskViewModel: ObservableObject {
    @Injected var tasksRepository: TaskRepository
    
    @Published var task = Task.placeholder()
    @Published var modified = false
    
    var list: ListModel
    
    private var cancellable = Set<AnyCancellable>()
    
    init(list: ListModel) {
        self.list = list
        
        self.$task
            .dropFirst()
            .sink { [weak self] _ in
                self?.modified = true
            }
            .store(in: &cancellable)
        
    }
    
    func save() {
        guard let listID = list.id else {
            print("DEBUG: Unable to add task, listID is missing.")
            return
        }
        
        var userTask = task
        userTask.listID = listID
        
        tasksRepository.addTask(userTask)
    }
}
