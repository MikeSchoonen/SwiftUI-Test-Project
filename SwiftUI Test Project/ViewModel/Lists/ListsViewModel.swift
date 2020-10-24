//
//  ListsViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 01/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class ListsViewModel: ObservableObject {
    @Injected var listsRepository: ListRepository
    @Published var listCellViewModels = [ListCellViewModel]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        listsRepository.$lists.map { lists in
            lists.map { list in
                ListCellViewModel(list: list)
            }
        }
        .assign(to: \.listCellViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func removeList(atOffsets indexSet: IndexSet) {
        let viewModels = indexSet.lazy.map { self.listCellViewModels[$0] }
        viewModels.forEach { listsRepository.removeList($0.list) }
    }
    
    func removeList(_ listCellViewModel: ListCellViewModel) {
        listsRepository.removeList(listCellViewModel.list)
    }
}
