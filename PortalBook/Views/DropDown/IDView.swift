//
//  IDView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/18/24.
//

import SwiftUI
import StudentVue

struct IDView: View {
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var info: StudentVueApi.StudentInfo? {
        didSet {
            if info == nil {
                refresh.toggle()
            }
        }
    }

    @State var selectedIDPage = 0

    var body: some View {
        NavigationStack {
            VStack {
                if let info = info {
                    if let photo = info.photo,
                       let data = Data(base64Encoded: photo),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                    }

                    Spacer()

                    Picker("", selection: $selectedIDPage) {
                        Text("Barcode")
                            .tag(0)
                        Text("QR Code")
                            .tag(1)
                    }
                    .pickerStyle(.segmented)

                    TabView(selection: $selectedIDPage) {
                        Image(code: info.permID, .code128Barcode)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .tag(0)

                        Image(code: info.permID, .qrCode)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .tag(1)
                    }
                    .tabViewStyle(.page)

                    Spacer()

                    Group {
                        Text(info.permID)
                        Text(info.formattedName)
                        Text("Current school: \(info.currentSchool)")
                    }
                } else if loadingMessage == .empty {
                    Text("Unable to retrieve student information for id")
                }
            }
            .navigationTitle("Student ID")
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
                        info = try await client.api.getStudentInfo()
                    } catch {
                        print("error: \(error.localizedDescription)")
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

}
