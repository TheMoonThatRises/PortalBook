//
//  CourseHistoryView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/18/24.
//

import SwiftUI
import StudentVue

struct CourseHistoryView: View {
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var courseHistory: StudentVueScraper.CourseHistory? {
        didSet {
            courseHistory == nil ? refresh.toggle() : nil
        }
    }

    var body: some View {
        NavigationStack {

        }
        .navigationTitle("Course History")
        .toolbar {
            ToolbarItem {
                Button {
                    courseHistory = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { courseHistory == nil ? courseHistory = nil : nil }
        .onChange(of: refresh) {
            Task {
                defer {
                    loadingMessage = .empty
                }

                loadingMessage = .loadingCourseHistory

                do {
                    print(try await client.scraper.autoThrowApi(endpoint: .courseHistory).html)
                    courseHistory = try await client.scraper.getCourseHistory()
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
