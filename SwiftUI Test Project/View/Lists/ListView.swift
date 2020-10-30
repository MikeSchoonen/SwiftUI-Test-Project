//
//  ListView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 24/08/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @ObservedObject var listsViewModel = ListsViewModel()
    
    @State private var activeSheet: ListViewSheet? = nil
    @State private var showActionSheet = false
    
    @State var indexSet: IndexSet?
    @State var listCellViewModel: ListCellViewModel?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    ForEach(listsViewModel.listCellViewModels) { listCellViewModel in
                        NavigationLink(destination: TasksView(list: listCellViewModel.list)) {
                            ListCellView(listCellViewModel: listCellViewModel)
                                .contextMenu {
                                    Button(action: {
                                        listCellViewModel.favorite()
                                    }) {
                                        Text("Favorite")
                                        Image(systemName: "star")
                                            .foregroundColor(.yellow)
                                    }
                                    Button(action: {
                                        self.listCellViewModel = listCellViewModel
                                        activeSheet = .edit
                                    }) {
                                        Text("Edit")
                                        Image(systemName: "pencil")
                                    }
                                    Button(action: {
                                        self.listCellViewModel = listCellViewModel
                                        showActionSheet.toggle()
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                        }
                    }
                    .onDelete { indexSet in
                        self.indexSet = indexSet
                        showActionSheet.toggle()
                    }
                }
                Button(action: {
                    activeSheet = .add
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("New List")
                    }
                }
                .padding()
                .accentColor(Color(settings.themeColor.systemColor))
            }
            .navigationBarTitle("SwiftUI Test Project")
            .navigationBarItems(trailing:
                Button(action: {
                    activeSheet = .settings
                }, label: {
                    Image(systemName: "gear").foregroundColor(Color(UIColor.systemBlue))
                })
            )
            .sheet(item: $activeSheet) { activeSheet in
                switch activeSheet {
                case .add:
//                    AddEditListView(list: nil)
                    AddListView()
                case .edit:
                    if let list = listCellViewModel?.list {
//                        AddEditListView(list: list)
                        EditListView(list: list)
                    }
                case .settings:
                    SettingsView().environmentObject(settings)
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Are you sure?"), message: Text("All underlaying tasks will be deleted."), buttons: [.destructive(Text("Delete"), action: {
                    if let indexSet = self.indexSet {
                        self.listsViewModel.removeList(atOffsets: indexSet)
                        return
                    } else if let vm = self.listCellViewModel {
                        self.listsViewModel.removeList(vm)
                    }
                }), .cancel()])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
