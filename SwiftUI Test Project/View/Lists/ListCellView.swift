//
//  ListCellView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 02/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI

struct ListCellView: View {
    @EnvironmentObject private var settings: SettingsViewModel
    let listCellViewModel: ListCellViewModel
    
    var body: some View {
        HStack {
            Image(systemName: listCellViewModel.symbol)
                .foregroundColor(Color(listCellViewModel.isFavorite ? settings.themeColor.systemColor : .label))
                .onTapGesture { self.listCellViewModel.favorite() }
            Text(listCellViewModel.name)
        }
    }
}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        ListCellView(listCellViewModel: ListCellViewModel(list: ListModel(name: "Hello World!")))
            .frame(width: 400, height: 50)
    }
}
