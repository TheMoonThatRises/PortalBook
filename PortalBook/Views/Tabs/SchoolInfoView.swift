//
//  SchoolInfoView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import SwiftUI
import StudentVue
import AlertToast

struct SchoolInfoView: View {
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var info: StudentVueApi.SchoolInfo? {
        didSet {
            if info == nil {
                refresh.toggle()
            }
        }
    }

    var body: some View {
        NavigationStack {

        }
        .navigationTitle("School Information")
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
                    info = try await client.api.getSchoolInfo()
                    print(info)
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
