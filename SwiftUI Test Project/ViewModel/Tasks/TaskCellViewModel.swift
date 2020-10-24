//
//  TaskCellViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 03/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class TaskCellViewModel: ObservableObject, Identifiable {
    @Injected var tasksRepository: TaskRepository
    @Published var task: Task
    
    var id = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    static func newTask() -> TaskCellViewModel {
        TaskCellViewModel(task: Task(listID: "", name: "", finished: false))
    }
    
    init(task: Task) {
        self.task = task
        
        $task
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellable)
        
        $task
            .dropFirst()
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink { [weak self] list in
                self?.tasksRepository.updateTask(task)
            }
            .store(in: &cancellable)
    }
    
    var name: String {
        task.name
    }
}
