//
//  HomeView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/26/23.
//

import SwiftUI
import StudentVue
import CachedAsyncImage

struct HomeView: View {
    var client: StudentVue

    @Binding var viewIndex: ViewIndex

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    GradebookView(client: client,
                                  loadingMessage: $loadingMessage,
                                  errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Gradebook", image: Image(systemName: "a"))
                }
                NavigationLink {
                    ScheduleView(client: client,
                                 loadingMessage: $loadingMessage,
                                 errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Schedule", image: Image(systemName: "clock.fill"))
                }
                NavigationLink {
                    InfoView(client: client,
                             loadingMessage: $loadingMessage,
                             errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "All Info", image: Image(systemName: "info.square.fill"))
                }
//                HomeViewRow(title: "Mail", image: Image(systemName: "envelope.fill"))
//                HomeViewRow(title: "Calendar", image: Image(systemName: "calendar"))
//                HomeViewRow(title: "Attendance", image: Image(systemName: "clock.badge.checkmark.fill"))
//                HomeViewRow(title: "Gradebook", image: Image(systemName: "a"))
//                HomeViewRow(title: "My Info", image: Image(systemName: "info.square.fill"))
//                HomeViewRow(title: "Schedule", image: Image(systemName: "clock.fill"))
//                HomeViewRow(title: "Health", image: Image(systemName: "heart.text.square.fill"))
//                HomeViewRow(title: "School Info", image: Image(systemName: "building.2.fill"))
//                HomeViewRow(title: "Fee", image: Image(systemName: "wallet.pass.fill"))
//                HomeViewRow(title: "Conference", image: Image(systemName: "person.3.fill"))
//                HomeViewRow(title: "Report Card", image: Image(systemName: "doc.text.fill"))
//                HomeViewRow(title: "Course History", image: Image(systemName: "globe.desk.fill"))
//                HomeViewRow(title: "Course Request", image: Image(systemName: "rectangle.inset.filled.and.person.filled"))
//                HomeViewRow(title: "MTSS", image: Image(systemName: "pyramid.fill"))
//                HomeViewRow(title: "Assessment", image: Image(systemName: "studentdesk"))
//                HomeViewRow(title: "Graduation Requirements", image: Image(systemName: "graduationcap.fill"))
            }
            .navigationTitle("PortalBook")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("Settings") {

                        }
                        Button("Logout") {
                            Settings.shared.didManuallyLogout = true

                            Task {
                                do {
                                    _ = try await client.scraper.logout()
                                    client.updateCredentials(username: "", password: "")
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                            }

                            withAnimation(.easeInOut) {
                                viewIndex = .loginView
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}
