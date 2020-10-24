//
//  AddEditListViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 25/10/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class AddEditListViewModel: ObservableObject {
    @Injected var listsRepository: ListRepository
    
    @Published var list: ListModel
    @Published var modified = false
    
    private(set) var isNewList: Bool
    private var cancellable = Set<AnyCancellable>()
    
    init(list: ListModel?) {
        if let list = list {
            isNewList = false
            self.list = list
        } else {
            isNewList = true
            self.list = ListModel.placeholder()
        }
        
        self.$list
            .dropFirst()
            .sink { [weak self] _ in
                self?.modified = true
            }
            .store(in: &cancellable)
    }
    
    func save() {
        if isNewList {
            add()
        } else {
            update()
        }
    }
    
    private func add() {
        listsRepository.addList(list)
    }
    
    private func update() {
        listsRepository.updateList(list)
    }
}
