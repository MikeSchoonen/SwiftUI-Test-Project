//
//  TaskCellView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 25/10/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct TaskCellView: View {
    @EnvironmentObject private var settings: SettingsViewModel
    let taskCellViewModel: TaskCellViewModel
    
    var body: some View {
        HStack {
            Image(systemName: listCellViewModel.symbol)
                .foregroundColor(Color(listCellViewModel.isFavorite ? settings.themeColor.systemColor : .label))
                .onTapGesture { self.listCellViewModel.favorite() }
            Text(listCellViewModel.name)
        }
    }
}

struct TasksCellView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCellView()
    }
}
