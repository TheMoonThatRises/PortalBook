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
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false

    @State var selectedImmunization: StudentVueApi.HealthImmunizationListing?

    var body: some View {
        NavigationStack {
            if let info = dataCache.studentHealthInfo {
                ScrollView {
                    Text("Health Immunizations")
                        .bold()
                        .font(.title)

                    Grid {
                        ForEach(info.healthImmunizationListing) { immunization in
                            Divider()
                            GridRow {
                                Button {
                                    selectedImmunization = immunization
                                } label: {
                                    HStack {
                                        Text(immunization.name)
                                        Spacer()
                                        if immunization.immunizationDates.isEmpty {
                                            Text(immunization.compliantMessage)
                                        } else {
                                            Text(
                                                immunization.immunizationDates
                                                    .last?.formatted(date: .numeric, time: .omitted)
                                                ?? immunization.compliantMessage
                                            )
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                }
            } else if loadingMessage == .empty {
                Text("Unable to retrieve health information")
            }
        }
        .navigationTitle("Health Information")
        .toolbar {
            ToolbarItem {
                Button {
                    refresh.toggle()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            if !dataCache.studentHealthInfoLoaded {
                loadingMessage = .loadingHealthInfo
            }
        }
        .onChange(of: dataCache.studentHealthInfoLoaded) {
            loadingMessage = dataCache.studentHealthInfoLoaded ? .empty : .loadingHealthInfo
        }
        .onChange(of: refresh) {
            do {
                try dataCache.reloadStudentHealthInfo(client: client, force: true)
            } catch {
                print("error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
        .sheet(item: $selectedImmunization) { selected in
            DetailedImmunizationView(immunization: selected)
        }
    }
}

struct DetailedImmunizationView: View {
    @Environment(\.dismiss) var dismiss

    var immunization: StudentVueApi.HealthImmunizationListing

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Compliant Message")
                    Spacer()
                    Text(immunization.compliantMessage)
                }
                Divider()
                GridRow {
                    Text("Compliant")
                    Spacer()
                    Text(immunization.compliant ? "True" : "False")
                }
                Divider()
                GridRow {
                    Text("Immunization Dates")
                    Spacer()
                    VStack {
                        ForEach(immunization.immunizationDates, id: \.self) { date in
                            Text(date.formatted(date: .numeric, time: .omitted))
                        }
                    }
                }
                Divider()
            }
            .padding()
            .navigationTitle(immunization.name)
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
