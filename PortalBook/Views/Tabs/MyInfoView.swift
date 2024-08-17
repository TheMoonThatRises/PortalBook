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

    @State var selectedEmergencyContact: StudentVueApi.EmergencyContact?
    @State var selectedPhysician: StudentVueApi.PhysicianInfo?
    @State var selectedDentist: StudentVueApi.DentistInfo?
    @State var selectedUserDefinedItem: StudentVueApi.UserDefinedItem?

    var body: some View {
        NavigationStack {
            if let info = info {
                ScrollView {
                    if let photo = info.photo,
                       let data = Data(base64Encoded: photo),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                    }

                    Spacer()

                    Grid {
                        Divider()
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
                            if let email = URL(string: "mailto:\(info.email)") {
                                Button {
                                    UIApplication.shared.open(email)
                                } label: {
                                    Text(info.email)
                                }
                            } else {
                                Text(info.email)
                            }
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
                                if let email = URL(string: "mailto:\(info.homeRoomTeacherEmail)") {
                                    Button {
                                        UIApplication.shared.open(email)
                                    } label: {
                                        Text(info.homeRoomTeacherEmail)
                                    }
                                } else {
                                    Text(info.homeRoomTeacherEmail)
                                }
                            }
                        }
                    }
                    .padding()

                    Divider()
                        .padding()

                    Text("Emergency Contacts")
                        .bold()
                        .font(.title)

                    Grid {
                        ForEach(info.emergencyContacts, id: \.name) { contact in
                            Divider()
                            GridRow {
                                Button {
                                    selectedEmergencyContact = contact
                                } label: {
                                    Text(contact.name)
                                        .padding()
                                }
                            }
                        }
                    }

                    Divider()
                        .padding()

                    Text("Health Information")
                        .bold()
                        .font(.title)

                    Grid {
                        Divider()
                        GridRow {
                            Button {
                                selectedPhysician = info.physicianInfo
                            } label: {
                                HStack {
                                    Text("Physician")
                                    Spacer()
                                    Text(info.physicianInfo.name)
                                }
                                .padding()
                            }
                        }
                        Divider()
                        GridRow {
                            Button {
                                selectedDentist = info.dentistInfo
                            } label: {
                                HStack {
                                    Text("Dentist")
                                    Spacer()
                                    Text(info.dentistInfo.name)
                                }
                                .padding()
                            }
                            .padding()
                        }
                    }

                    Divider()
                        .padding()

                    Text("User Defined items")
                        .bold()
                        .font(.title)

                    Grid {
                        ForEach(info.userDefinedItems) { userItem in
                            Divider()
                            GridRow {
                                Button {
                                    selectedUserDefinedItem = userItem
                                } label: {
                                    Text(userItem.itemLabel)
                                        .padding()
                                }
                                .padding()
                            }
                        }
                    }
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
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
        .sheet(item: $selectedEmergencyContact) { selected in
            DetailedEmergencyContactView(contact: selected)
        }
        .sheet(item: $selectedPhysician) { selected in
            DetailedPhysicianView(physician: selected)
        }
        .sheet(item: $selectedDentist) { selected in
            DetailedDentistView(dentist: selected)
        }
        .sheet(item: $selectedUserDefinedItem) { selected in
            DetailedUserDefinedItemView(userItem: selected)
        }
    }
}

struct DetailedEmergencyContactView: View {
    @Environment(\.dismiss) var dismiss

    var contact: StudentVueApi.EmergencyContact

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Relationship")
                    Spacer()
                    Text(contact.relationship)
                }
                Divider()
                GridRow {
                    Text("Mobile Phone")
                    Spacer()
                    Text(contact.mobilePhone)
                }
                Divider()
                GridRow {
                    Text("Home Phone")
                    Spacer()
                    Text(contact.homePhone)
                }
                Divider()
                GridRow {
                    Text("Work Phone")
                    Spacer()
                    Text(contact.workPhone)
                }
                Divider()
                GridRow {
                    Text("Other Phone")
                    Spacer()
                    Text(contact.otherPhone)
                }
            }
            .padding()
            .navigationTitle(contact.name)
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

struct DetailedPhysicianView: View {
    @Environment(\.dismiss) var dismiss

    var physician: StudentVueApi.PhysicianInfo

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Name")
                    Spacer()
                    Text(physician.name)
                }
                Divider()
                GridRow {
                    Text("Hospital")
                    Spacer()
                    Text(physician.hospital)
                }
                Divider()
                GridRow {
                    Text("Phone")
                    Spacer()
                    Text(physician.phone)
                }
                Divider()
                GridRow {
                    Text("Extension")
                    Spacer()
                    Text(physician.extn)
                }
            }
            .padding()
            .navigationTitle("Physician Info")
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

struct DetailedDentistView: View {
    @Environment(\.dismiss) var dismiss

    var dentist: StudentVueApi.DentistInfo

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Name")
                    Spacer()
                    Text(dentist.name)
                }
                Divider()
                GridRow {
                    Text("Office")
                    Spacer()
                    Text(dentist.office)
                }
                Divider()
                GridRow {
                    Text("Phone")
                    Spacer()
                    Text(dentist.phone)
                }
                Divider()
                GridRow {
                    Text("Extension")
                    Spacer()
                    Text(dentist.extn)
                }
            }
            .padding()
            .navigationTitle("Dentist Info")
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

struct DetailedUserDefinedItemView: View {
    @Environment(\.dismiss) var dismiss

    var userItem: StudentVueApi.UserDefinedItem

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Value")
                    Spacer()
                    Text(userItem.value)
                }
                Divider()
                GridRow {
                    Text("Source Element")
                    Spacer()
                    Text(userItem.sourceElement)
                }
                Divider()
                GridRow {
                    Text("Item Type")
                    Spacer()
                    Text(userItem.itemType)
                }
            }
            .padding()
            .navigationTitle(userItem.itemLabel)
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
