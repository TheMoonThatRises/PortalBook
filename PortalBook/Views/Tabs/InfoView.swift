//
//  InfoView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import SwiftUI
import StudentVue

struct InfoView: View {
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    MyInfoView(client: $client,
                               loadingMessage: $loadingMessage,
                               errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "My Info", image: Image(systemName: "person.crop.square.fill"))
                }
                NavigationLink {
                    SchoolInfoView(client: $client,
                                   loadingMessage: $loadingMessage,
                                   errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "School Info", image: Image(systemName: "building.2.fill"))
                }
                NavigationLink {
                    HealthInfoView(client: $client,
                                   loadingMessage: $loadingMessage,
                                   errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Health Info", image: Image(systemName: "heart.text.square.fill"))
                }
            }
            .environmentObject(dataCache)
        }
        .navigationTitle("All Info")
        .onAppear {
            loadingMessage = .empty
        }
    }
}
