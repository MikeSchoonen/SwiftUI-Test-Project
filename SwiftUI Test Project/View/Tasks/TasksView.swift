//
//  TasksView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 03/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI
import Resolver

struct TasksView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @ObservedObject var tasksViewModel: TasksViewModel
    
    @State private var activeSheet: ActiveSheet? = nil
    
    var list: ListModel
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(tasksViewModel.taskCellViewModels) { taskCellViewModel in
                    Text(taskCellViewModel.task.name)
                }
                .onDelete(perform: tasksViewModel.removeTask(atOffsets:))
            }
            Button(action: {
                activeSheet = .add
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("New Task")
                }
            }
            .padding()
            .accentColor(Color(settings.themeColor.systemColor))
        }
        .navigationBarTitle(Text("Tasks"), displayMode: .inline)
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
                AddTaskView(list: list)
            case .settings:
                SettingsView().environmentObject(settings)
            }
        }
    }
    
    init(list: ListModel) {
        self.list = list
        tasksViewModel = TasksViewModel(list: list)
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(list: ListModel.placeholder())
    }
}
