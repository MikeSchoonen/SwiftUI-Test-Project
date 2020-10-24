//
//  EditListViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 24/10/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class EditListViewModel: ObservableObject {
    @Injected var listsRepository: ListRepository
    
    @Published var list: ListModel
    @Published var modified = false
    
    private var cancellable = Set<AnyCancellable>()
    
    init(list: ListModel) {
        self.list = list
        
        self.$list
            .dropFirst()
            .sink { [weak self] _ in
                self?.modified = true
            }
            .store(in: &cancellable)
    }
    
    func save() {
        listsRepository.updateList(list)
    }
}
