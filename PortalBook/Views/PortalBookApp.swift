//
//  PortalBookApp.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/9/23.
//

import SwiftUI
import StudentVue
import AlertToast

enum ViewIndex {
    case districtView, loginView, homeView
}

@main
struct PortalBookApp: App {
    @StateObject private var viewModel = PortalBookVM()

    @State private var viewIndex: ViewIndex = .loginView
    @State private var studentVueClient = StudentVue(domain: Settings.shared.domain, username: "", password: "")

    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch viewIndex {
                case .districtView:
                    DistrictSelectorView(client: $studentVueClient,
                                         setView: $viewIndex,
                                         loadingMessage: $viewModel.loadingMessage,
                                         errorMessage: $viewModel.errorMessage)
                case .loginView:
                    LoginView(client: $studentVueClient,
                              viewIndex: $viewIndex,
                              loadingMessage: $viewModel.loadingMessage,
                              errorMessage: $viewModel.errorMessage)
                case .homeView:
                    HomeView(client: studentVueClient,
                             viewIndex: $viewIndex,
                             loadingMessage: $viewModel.loadingMessage,
                             errorMessage: $viewModel.errorMessage)
                }
            }
            .toast(isPresenting: $viewModel.showLoadingToast) {
                AlertToast(displayMode: .alert, type: .loading, title: viewModel.loadingMessage.rawValue)
            }
            .toast(isPresenting: $viewModel.showErrorMessage) {
                AlertToast(displayMode: .banner(.pop), type: .error(.red), title: viewModel.errorMessage)
            }
            .onAppear {
                guard !Settings.shared.domain.isEmpty else {
                    return viewIndex = .districtView
                }

                if Settings.shared.rememberLogin && !Settings.shared.didManuallyLogout {
                    Task {
                        defer {
                            viewModel.loadingMessage = .empty
                        }

                        do {
                            viewModel.loadingMessage = .retreivingCredentials

                            let creds = try await PortalKeychain.shared.getItem(domain: Settings.shared.domain)

                            viewModel.loadingMessage = .loggingIn

                            studentVueClient.updateCredentials(username: creds.username, password: creds.password)

                            _ = try await studentVueClient.scraper.login()

                            withAnimation(.easeInOut) {
                                viewIndex = .homeView
                            }
                        } catch {
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }

    }
}
