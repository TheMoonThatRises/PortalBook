//
//  HomeView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/26/23.
//

import SwiftUI
import StudentVue

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
                    NavigationLinkRow(title: "Schedule", image: Image(systemName: "clock"))
                }
                NavigationLink {
                    InfoView(client: client,
                             loadingMessage: $loadingMessage,
                             errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "All Info", image: Image(systemName: "info.square"))
                }
                NavigationLink {
                    AttendanceView(client: client,
                                   loadingMessage: $loadingMessage,
                                   errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Attendance", image: Image(systemName: "calendar"))
                }
                NavigationLink {
                    CourseHistoryView(client: client,
                                      loadingMessage: $loadingMessage,
                                      errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Course History", image: Image(systemName: "book.pages"))
                }

//                NavigationLinkRow(title: "Mail", image: Image(systemName: "envelope.fill"))
//                NavigationLinkRow(title: "Calendar", image: Image(systemName: "calendar"))
//                NavigationLinkRow(title: "Fee", image: Image(systemName: "wallet.pass.fill"))
//                NavigationLinkRow(title: "Conference", image: Image(systemName: "person.3.fill"))
//                NavigationLinkRow(title: "Report Card", image: Image(systemName: "doc.text.fill"))
//                NavigationLinkRow(title: "Course Request", image: Image(systemName: "rectangle.inset.filled.and.person.filled"))
//                NavigationLinkRow(title: "MTSS", image: Image(systemName: "pyramid.fill"))
//                NavigationLinkRow(title: "Assessment", image: Image(systemName: "studentdesk"))
//                NavigationLinkRow(title: "Graduation Requirements", image: Image(systemName: "graduationcap.fill"))
            }
            .navigationTitle("PortalBook")
            .toolbar {
                ToolbarItem {
                    Menu {
                        NavigationLink {
                            IDView(client: client,
                                   loadingMessage: $loadingMessage,
                                   errorMessage: $errorMessage)
                        } label: {
                            Text("Student ID")
                        }
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
