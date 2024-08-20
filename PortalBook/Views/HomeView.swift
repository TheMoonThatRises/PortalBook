//
//  HomeView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/26/23.
//

import SwiftUI
import StudentVue

struct HomeView: View {
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var viewIndex: ViewIndex

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    GradebookView(client: $client,
                                  loadingMessage: $loadingMessage,
                                  errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Gradebook", image: Image(systemName: "a"))
                }
                NavigationLink {
                    ScheduleView(client: $client,
                                 loadingMessage: $loadingMessage,
                                 errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Schedule", image: Image(systemName: "clock"))
                }
                NavigationLink {
                    CalendarView(client: $client,
                                 loadingMessage: $loadingMessage,
                                 errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Calendar", image: Image(systemName: "calendar"))
                }
                NavigationLink {
                    AttendanceView(client: $client,
                                   loadingMessage: $loadingMessage,
                                   errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Attendance", image: Image(systemName: "person.and.person"))
                }
                NavigationLink {
                    InfoView(client: $client,
                             loadingMessage: $loadingMessage,
                             errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "All Info", image: Image(systemName: "info.square"))
                }
                NavigationLink {
                    CourseHistoryView(client: $client,
                                      loadingMessage: $loadingMessage,
                                      errorMessage: $errorMessage)
                } label: {
                    NavigationLinkRow(title: "Course History", image: Image(systemName: "book.pages"))
                }

//                NavigationLinkRow(title: "Mail", image: Image(systemName: "envelope.fill"))
//                NavigationLinkRow(title: "Fee", image: Image(systemName: "wallet.pass.fill"))
            }
            .environmentObject(dataCache)
            .navigationTitle("PortalBook")
            .toolbar {
                ToolbarItem {
                    Menu {
                        NavigationLink {
                            IDView(client: $client,
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
                    .environmentObject(dataCache)
                }
            }
            .onAppear {
                loadingMessage = .empty

                do {
                    try dataCache.reloadCache(client: client, force: false)
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
