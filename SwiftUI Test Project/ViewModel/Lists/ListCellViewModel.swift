//
//  ListCellViewModel.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 01/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import Resolver

class ListCellViewModel: ObservableObject, Identifiable {
    @Injected var listsRepository: ListRepository
    @Injected var authenticationService: AuthenticationService
    @Published var list: ListModel
    
    var id = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    private var userID = ""
    
    static func newList() -> ListCellViewModel {
        ListCellViewModel(list: ListModel(name: ""))
    }
    
    init(list: ListModel) {
        self.list = list
        
        $list
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellable)
        
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userID, on: self)
            .store(in: &cancellable)
    }
    
    func favorite() {
        if list.favorite.contains(userID) {
            if let index = list.favorite.firstIndex(where: { $0 == userID }) {
                list.favorite.remove(at: index)
                listsRepository.updateList(list)
            }
        } else {
            list.favorite.append(userID)
            listsRepository.updateList(list)
        }
    }
    
    var name: String {
        list.name
    }
    
    var symbol: String {
        list.symbol
    }
    
    var isFavorite: Bool {
        list.favorite.contains(userID)
    }
}
