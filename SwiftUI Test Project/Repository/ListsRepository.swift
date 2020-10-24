//
//  ListsRepository.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 01/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import Resolver

class BaseListRepository {
    @Published var lists = [ListModel]()
}

protocol ListRepository: BaseListRepository {
    func addList(_ list: ListModel)
    func removeList(_ list: ListModel)
    func updateList(_ list: ListModel)
}

class TestDataListRepository: BaseListRepository, ListRepository, ObservableObject {
    override init() {
        super.init()
        self.lists = testLists
    }
    
    func addList(_ list: ListModel) {
        lists.append(list)
    }
    
    func removeList(_ list: ListModel) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists.remove(at: index)
        }
    }
    
    func updateList(_ list: ListModel) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
        }
    }
}

class LocalListRepository: BaseListRepository, ListRepository, ObservableObject {
    private let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override init() {
        super.init()
        loadData()
    }
    
    func addList(_ list: ListModel) {
        lists.append(list)
        saveData()
    }
    
    func removeList(_ list: ListModel) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists.remove(at: index)
            saveData()
        }
    }
    
    func updateList(_ list: ListModel) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
            saveData()
        }
    }
    
    private func loadData() {
        do {
            if let url = urls.first {
                let fileURL = url.appendingPathComponent("lists").appendingPathExtension("json")
                let data = try Data(contentsOf: fileURL)
                let lists = try JSONDecoder().decode([ListModel].self, from: data)
                self.lists = lists
            }
        } catch {
            print("DEBUG: Failed decoding and load data from disk.")
        }
    }
    
    private func saveData() {
        do {
            if let url = urls.first {
                let fileURL = url.appendingPathComponent("lists").appendingPathExtension("json")
                let data = try JSONEncoder().encode(self.lists)
                try data.write(to: fileURL, options: .atomic)
            }
        } catch {
            print("DEBUG: Failed encoding and saving to disk.")
        }
    }
}

class FirestoreListRepository: BaseListRepository, ListRepository, ObservableObject {
    private let db = Firestore.firestore()
    @Injected var authenticationService: AuthenticationService
    @LazyInjected var tasksRepository: TaskRepository
    
    private let listsPath = "lists"
    private let tasksPath = "tasks"
    private var userID = "unknown"
    
    private var listenerRegistration: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userID, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    func addList(_ list: ListModel) {
        do {
            var userList = list
            userList.userID = userID
            let _ = try db.collection(listsPath).addDocument(from: userList)
        } catch {
            print("DEBUG: Unable to add List")
        }
    }
    
    func updateList(_ list: ListModel) {
        guard let listID = list.id else {
            print("DEBUG: Cant't update List, listID is missing")
            return
        }
        
        do {
            let _ = try db.collection(listsPath).document(listID).setData(from: list)
        } catch {
            print("DEBUG: Unable to update list")
        }
    }
    
    func removeList(_ list: ListModel) {
        guard let listID = list.id else {
            print("DEBUG: Cant't remove List, listID is missing")
            return
        }
        
        db.collection(listsPath).document(listID).delete { error in
            if let _ = error {
                print("DEBUG: Error deleting \(listID)")
                return
            }
        }
        
        tasksRepository.removeTasks(for: listID)
    }
    
    private func loadData() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
        }
        
        print("DEBUG: Fetch lists")
        
        listenerRegistration = db.collection(listsPath).whereField("userID", isEqualTo: userID).order(by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No documents")
                return
            }
            
            self.lists = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: ListModel.self)
                } catch {
                    print("DEBUG: Unable to decode ListModel while fetching the data")
                    return nil
                }
            }
        }
    }
}

#if DEBUG
let testLists = [
    ListModel(id: "list1", userID: "aaa", name: "Hello World"),
    ListModel(id: "list1", userID: "aaa", name: "Goodbye World"),
    ListModel(id: "list1", userID: "bbb", name: "Hello World"),
    ListModel(id: "list1", userID: "bbb", name: "Goodbye World"),
    ListModel(id: "list2", userID: "aaa", name: "List 2 Hello World"),
    ListModel(id: "list2", userID: "aaa", name: "List 2 Goodbye World"),
    ListModel(id: "list2", userID: "bbb", name: "List 2 Hello World"),
    ListModel(id: "list2", userID: "bbb", name: "List 2 Goodbye World")
]
#endif
