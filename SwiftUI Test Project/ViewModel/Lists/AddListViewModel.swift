//
//  AddListViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 02/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI
import Combine
import Resolver

class AddListViewModel: ObservableObject {
    @Injected var listsRepository: ListRepository
    
    @Published var list = ListModel.placeholder()
    @Published var modified = false
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        self.$list
            .dropFirst()
            .sink { [weak self] _ in
                self?.modified = true
            }
            .store(in: &cancellable)
    }
    
    func save() {
        listsRepository.addList(list)
    }
}
