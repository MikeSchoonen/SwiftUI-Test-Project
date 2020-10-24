//
//  AddTaskView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 03/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var addTaskViewModel: AddTaskViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $addTaskViewModel.task.name)
                }
            }
            .navigationBarTitle(Text("Add new task"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { self.handleCancelTapped() },
                trailing: Button("Save") { self.handleSaveTapped() }.disabled(!addTaskViewModel.modified)
            )
        }
    }
    
    init(list: ListModel) {
        addTaskViewModel = AddTaskViewModel(list: list)
    }
    
    func handleCancelTapped() {
        dismiss()
    }
    
    func handleSaveTapped() {
        addTaskViewModel.save()
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(list: ListModel.placeholder())
    }
}
