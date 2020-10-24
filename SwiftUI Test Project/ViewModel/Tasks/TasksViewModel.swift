//
//  TasksViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 03/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class TasksViewModel: ObservableObject {
    @Injected var tasksRepository: TaskRepository
    @Published var taskCellViewModels = [TaskCellViewModel]()
    
    private var cancellables = Set<AnyCancellable>()
    private var list: ListModel
    
    init(list: ListModel) {
        print("DEBUG: TasksViewModel is created")
        self.list = list
        
        if let repository = tasksRepository as? FirestoreTaskRepository {
            repository.listID = list.id
        }
        
        tasksRepository.$tasks.map { tasks in
            tasks.map { task in
                TaskCellViewModel(task: task)
            }
        }
        .assign(to: \.taskCellViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func removeTask(atOffsets indexSet: IndexSet) {
        let viewModels = indexSet.lazy.map { self.taskCellViewModels[$0] }
        viewModels.forEach { tasksRepository.removeTask($0.task) }
    }
}
