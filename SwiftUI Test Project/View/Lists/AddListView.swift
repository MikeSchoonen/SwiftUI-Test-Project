//
//  AddListView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 02/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct AddListView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var addListViewModel = AddListViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $addListViewModel.list.name)
                    Picker("Pick an icon", selection: $addListViewModel.list.symbol) {
                        ForEach(SFSymbolsArray, id: \.self) {
                            PickerCell(symbol: $0).tag($0)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Add new list"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { self.handleCancelTapped() },
                trailing: Button("Save") { self.handleSaveTapped() }.disabled(!addListViewModel.modified)
            )
        }
    }
    
    func handleCancelTapped() {
        dismiss()
    }
    
    func handleSaveTapped() {
        addListViewModel.save()
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct PickerCell: View {
    var symbol: String
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
            Text(symbol)
        }
    }
}

struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        AddListView()
    }
}
