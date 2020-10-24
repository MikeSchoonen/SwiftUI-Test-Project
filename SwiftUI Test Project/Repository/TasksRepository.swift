//
//  TasksRepository.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 03/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Resolver

class BaseTaskRepository {
    @Published var tasks = [Task]()
}

protocol TaskRepository: BaseTaskRepository {
    func addTask(_ task: Task)
    func removeTask(_ task: Task)
    func updateTask(_ task: Task)
    func removeTasks(for listID: String)
}

class TestDataTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    override init() {
        super.init()
        self.tasks = testTasks
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func removeTasks(for listID: String) {
        tasks.removeAll { $0.listID == listID }
    }
}

class LocalTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    private let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override init() {
        super.init()
        loadData()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveData()
    }
    
    func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveData()
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }
    
    func removeTasks(for listID: String) {
        tasks.removeAll { $0.listID == listID }
        saveData()
    }
    
    private func loadData() {
        do {
            if let url = urls.first {
                let fileURL = url.appendingPathComponent("tasks").appendingPathExtension("json")
                let data = try Data(contentsOf: fileURL)
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                self.tasks = tasks
            }
        } catch {
            print("DEBUG: Failed decoding and load data from disk.")
        }
    }
    
    private func saveData() {
        do {
            if let url = urls.first {
                let fileURL = url.appendingPathComponent("tasks").appendingPathExtension("json")
                let data = try JSONEncoder().encode(self.tasks)
                try data.write(to: fileURL, options: .atomic)
            }
        } catch {
            print("DEBUG: Failed encoding and saving to disk.")
        }
    }
}

class FirestoreTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    private let db = Firestore.firestore()
    @Injected var authenticationService: AuthenticationService
    
    private let tasksPath = "tasks"
    private var userID = "unknown"
    var listID: String? {
        didSet {
            loadData()
        }
    }
    
    private var listenerRegistation: ListenerRegistration?
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
        
        loadData()
    }
    
    func addTask(_ task: Task) {
        do {
            var userTask = task
            userTask.userID = userID
            let _ = try db.collection(tasksPath).addDocument(from: userTask)
        } catch {
            print("DEBUG: Unable to add Task")
        }
    }
    
    func removeTask(_ task: Task) {
        guard let taskID = task.id else {
            print("DEBUG: Cant't remove Task, taskID is missing")
            return
        }
        
        db.collection(tasksPath).document(taskID).delete()
    }
    
    func updateTask(_ task: Task) {
        guard let taskID = task.id else {
            print("DEBUG: Cant't remove Task, taskID is missing")
            return
        }
        
        do {
            let _ = try db.collection(tasksPath).document(taskID).setData(from: task)
        } catch {
            print("DEBUG: Unable to update task")
        }
    }
    
    func removeTasks(for listID: String) {
        db.collection(tasksPath).whereField("listID", isEqualTo: listID).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No documents")
                return
            }
            
            let batch = self.db.batch()
            
            documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit()
        }
    }
    
    private func loadData() {
        if listenerRegistation != nil {
            listenerRegistation?.remove()
        }
        
        guard let listID = listID else {
            print("DEBUG: Empty listID")
            return
        }
        print("DEBUG: Fetch tasks with listID: \(listID), and userID: \(userID)")
        listenerRegistation = db.collection(tasksPath).whereField("listID", isEqualTo: listID).order(by: "createdTime", descending: true).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No documents")
                print("ListID: \(listID)")
                return
            }
            
            self.tasks = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: Task.self)
                } catch {
                    print("DEBUG: Unable to decode Task while fetching the data")
                    return nil
                }
            }
        }
    }
}

#if DEBUG
let testTasks = [
    Task(listID: "list1", name: "Firebase Implementation", finished: false),
    Task(listID: "list1", name: "Fixing UI", finished: false),
    Task(listID: "list1", name: "Debugging", finished: false),
    Task(listID: "list1", name: "Saying goodbye", finished: false),
    Task(listID: "list2", name: "List 2 Firebase Implementation", finished: false),
    Task(listID: "list2", name: "List 2 Fixing UI", finished: false),
    Task(listID: "list2", name: "List 2 Debugging", finished: false),
    Task(listID: "list2", name: "List 2 Saying goodbye", finished: false)
]
#endif
