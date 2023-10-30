//
//  DistrictSelectorView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/11/23.
//

import SwiftUI
import StudentVue
import AlertToast

struct DistrictSelectorView: View {
    @Binding var client: StudentVue

    @Binding var setView: ViewIndex

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var districtList: StudentVueApi.Districts?
    @State var zipCode = ""
    @State var invalidZipCode = false

    @State var loadDistrictsTask: Task<Void, Error>?

    var locationDelegate = LocationDelegate()

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            if !zipCode.isEmpty {
                if invalidZipCode {
                    Text("Invalid zip code: \(zipCode)")
                        .font(.headline)
                    Spacer()
                } else if let districtList {
                    List {
                        Section {
                            ForEach(districtList.districts, id: \.districtID) { district in
                                DistrictView(district: district)
                                    .onTapGesture {
                                        Settings.shared.domain = district.districtURL
                                            .description.replacing(/(https?):\/\//, with: "")

                                        if Settings.shared.domain.last == "/" {
                                            Settings.shared.domain = String(Settings.shared.domain.dropLast())
                                        }

                                        withAnimation(.easeInOut) {
                                            setView = .loginView
                                        }
                                    }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
                }
            }

            HStack(alignment: .center) {
                Spacer()
                Text("Zipcode:")
                TextField("12345", text: $zipCode)
                    .frame(width: 100)
                    .padding(2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.blue, lineWidth: 1)
                    }
                Spacer()
            }
        }
        .onChange(of: locationDelegate.location) {
            zipCode = locationDelegate.location ?? zipCode
        }
        .onChange(of: zipCode) {
            loadingMessage = .empty

            if let loadDistrictsTask, !loadDistrictsTask.isCancelled {
                loadDistrictsTask.cancel()
            }

            invalidZipCode = zipCode.trimmingCharacters(in: .numbers).isEmpty

            guard !invalidZipCode else {
                return
            }

            loadingMessage = .loadingDistricts

            loadDistrictsTask = Task { @MainActor in
                defer {
                    loadingMessage = .empty
                }

                districtList = try await StudentVueApi.getDistricts(zip: zipCode)

                districtList?.districts = Array(Set(districtList?.districts ?? []))
            }
        }
    }
}

struct DistrictView: View {
    var district: StudentVueApi.DistrictInfo

    var body: some View {
        HStack {
            VStack(alignment: .center) {
                HStack {
                    Text(district.districtName)
                        .font(.headline)

                    if !district.districtID.isEmpty {
                        Spacer()
                        Text(district.districtID)
                            .font(.caption)
                    }
                }
                Spacer()
                Text(district.districtAddress)
                    .font(.subheadline)
                Spacer()
                Text(district.districtURL.absoluteString)
                    .font(.caption)
            }
            Spacer()
            Text(">")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
            )
    }
}

#Preview {
    DistrictSelectorView(
        client: .constant(StudentVue(domain: "", username: "", password: "")),
        setView: .constant(.districtView),
        loadingMessage: .constant(.empty),
        errorMessage: .constant("")
    )
}
