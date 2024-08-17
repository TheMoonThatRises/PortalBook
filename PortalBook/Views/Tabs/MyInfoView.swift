//
//  MyInfoView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import SwiftUI
import StudentVue
import AlertToast

struct MyInfoView: View {
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

    var body: some View {
        NavigationStack {
            if let info = info {
                if let photo = info.photo, let data = Data(base64Encoded: photo), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                }

                Spacer()

                Grid {
                    GridRow {
                        let address = info.address.htmlDecoded.components(separatedBy: "<br>")

                        Text("Address")
                        Spacer()
                        VStack {
                            Text(address[0])
                            Text(address[1])
                        }
                    }
                    Divider()
                    GridRow {
                        Text("Phone")
                        Spacer()
                        Text(info.phone)
                    }
                    Divider()
                    GridRow {
                        Text("Student ID")
                        Spacer()
                        Text(info.permID)
                    }
                    Divider()
                    GridRow {
                        Text("Email")
                        Spacer()
                        Text(info.email)
                    }
                    Divider()
                    GridRow {
                        Text("Gender")
                        Spacer()
                        Text(info.gender)
                    }
                    Divider()
                    GridRow {
                        Text("Grade")
                        Spacer()
                        Text(info.grade)
                    }
                    Divider()
                    GridRow {
                        Text("Birthdate")
                        Spacer()
                        Text(info.birthDate.formatted())
                    }
                    Divider()
                    GridRow {
                        Text("Counselor")
                        Spacer()
                        Text(info.counselorName)
                    }
                    Divider()
                    GridRow {
                        Text("Home Room")
                        Spacer()
                        VStack {
                            Text(info.homeRoom)
                            Text(info.homeRoomTeacher)
                            Text(info.homeRoomTeacherEmail)
                        }
                    }
                    Divider()
                }
            } else if loadingMessage == .empty {
                Text("Unable to retrieve student information")
            }
        }
        .navigationTitle("My Information: \(info?.formattedName ?? "Unknown")")
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
                    print(info)
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
