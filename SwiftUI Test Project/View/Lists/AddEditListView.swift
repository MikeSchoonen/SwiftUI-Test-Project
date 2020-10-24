//
//  AddEditListView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 25/10/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct AddEditListView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var addEditListViewModel: AddEditListViewModel
    
    init(list: ListModel?) {
        addEditListViewModel = AddEditListViewModel(list: list)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $addEditListViewModel.list.name)
                    Picker("Pick an icon", selection: $addEditListViewModel.list.symbol) {
                        ForEach(SFSymbolsArray, id: \.self) {
                            PickerCell(symbol: $0).tag($0)
                        }
                    }
                }
            }
            .navigationBarTitle(Text(addEditListViewModel.isNewList ? "Edit list" : "Add new list"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { self.handleCancelTapped() },
                trailing: Button("Save") { self.handleSaveTapped() }.disabled(!addEditListViewModel.modified)
            )
        }
    }
    
    private func handleCancelTapped() {
        dismiss()
    }
    
    private func handleSaveTapped() {
        addEditListViewModel.save()
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
