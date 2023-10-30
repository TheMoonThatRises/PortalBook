//
//  PortalBookVM.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import Foundation

class PortalBookVM: ObservableObject {
    @Published var loadingMessage: LoadingMessages = .empty {
        didSet {
            showLoadingToast = loadingMessage != .empty
        }
    }
    @Published var errorMessage: String = "" {
        didSet {
            showErrorMessage = !errorMessage.isEmpty
        }
    }

    @Published var showLoadingToast: Bool = false
    @Published var showErrorMessage: Bool = false
}
