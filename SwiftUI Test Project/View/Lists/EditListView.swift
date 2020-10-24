//
//  EditListView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 24/10/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct EditListView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var editListViewModel: EditListViewModel
    
    init(list: ListModel) {
        editListViewModel = EditListViewModel(list: list)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $editListViewModel.list.name)
                    Picker("Pick an icon", selection: $editListViewModel.list.symbol) {
                        ForEach(SFSymbolsArray, id: \.self) {
                            PickerCell(symbol: $0).tag($0)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Update list"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { self.handleCancelTapped() },
                trailing: Button("Save") { self.handleSaveTapped() }.disabled(!editListViewModel.modified)
            )
        }
    }
    
    private func handleCancelTapped() {
        dismiss()
    }
    
    private func handleSaveTapped() {
        editListViewModel.save()
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditListView_Previews: PreviewProvider {
    static var previews: some View {
        EditListView(list: ListModel.placeholder())
    }
}
