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

    @State var selectedStaff: StudentVueApi.StaffInfo?

    var body: some View {
        NavigationStack {
            if let info = info {
                Text("School Info")
                    .bold()
                    .font(.title)

                Grid {
                    GridRow {
                        Text("Principal")
                        Spacer()
                        Text(info.principal)
                    }
                    Divider()
                    GridRow {
                        Text("Principal Email")
                        Spacer()
                        if let email = URL(string: "mailto:\(info.principalEmail)") {
                            Button {
                                UIApplication.shared.open(email)
                            } label: {
                                Text(info.principalEmail)
                            }
                        } else {
                            Text(info.principalEmail)
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
                        Text("Fax")
                        Spacer()
                        Text(info.phone2)
                    }
                    Divider()
                    GridRow {
                        Text("Address")
                        Spacer()
                        VStack {
                            Text(info.address)
                            Text("\(info.city), \(info.state) \(info.zip)")
                        }
                    }
                    if let website = info.homepage {
                        Divider()
                        GridRow {
                            Text("Website")
                            Spacer()
                            Text(.init("[\(website)](\(website))"))
                        }
                    }
                }
                .padding()

                Text("Staff List")
                    .bold()
                    .font(.title)

                List(info.staffList) { staff in
                    Button {
                        selectedStaff = staff
                    } label: {
                        Text(staff.name)
                            .padding()
                    }
                }
            } else if loadingMessage == .empty {
                Text("Unable to retrieve school information")
            }
        }
        .navigationTitle("\(info?.school ?? "School") Information")
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

                loadingMessage = .loadingSchoolInfo

                do {
                    info = try await client.api.getSchoolInfo()
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
        .sheet(item: $selectedStaff) { selected in
            DetailedStaffView(staff: selected)
        }
    }
}

struct DetailedStaffView: View {
    @Environment(\.dismiss) var dismiss

    var staff: StudentVueApi.StaffInfo

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Job Title")
                    Spacer()
                    Text(staff.title)
                }
                Divider()
                GridRow {
                    Text("Email")
                    Spacer()
                    if let email = URL(string: "mailto:\(staff.email)") {
                        Button {
                            UIApplication.shared.open(email)
                        } label: {
                            Text(staff.email)
                        }
                    } else {
                        Text(staff.email)
                    }
                }
                Divider()
                GridRow {
                    Text("Phone")
                    Spacer()
                    Text(staff.phone)
                }
                Divider()
                GridRow {
                    Text("Extension")
                    Spacer()
                    Text(staff.extn)
                }
                Divider()
                GridRow {
                    Text("Staff GU")
                    Spacer()
                    Text(staff.staffGU)
                }
                Divider()
            }
            .padding()
            .navigationTitle(staff.name)
            .toolbar {
                ToolbarItem {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
