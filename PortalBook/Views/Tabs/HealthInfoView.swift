//
//  HealthInfoView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import SwiftUI
import StudentVue
import AlertToast

struct HealthInfoView: View {
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var info: StudentVueApi.StudentHealthInfo? {
        didSet {
            if info == nil {
                refresh.toggle()
            }
        }
    }

    var body: some View {
        NavigationStack {

        }
        .navigationTitle("Health Information")
        .toolbar {
            ToolbarItem {
                Button {
                    info = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { info == nil ? info = nil : nil }
        .onChange(of: refresh) {
            Task {
                defer {
                    loadingMessage = .empty
                }

                loadingMessage = .loadingMyInfo

                do {
                    info = try await client.api.getHealthInfo()
                    print(info)
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
