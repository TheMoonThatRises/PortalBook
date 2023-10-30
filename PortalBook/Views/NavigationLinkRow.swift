//
//  NavigationLinkRow.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import SwiftUI


struct NavigationLinkRow: View {
    var title: String
    var image: Image

    var body: some View {
        HStack {
            image
                .resizable()
                .frame(width: 50, height: 50)
            Text(title)

            Spacer()
        }
    }

}
