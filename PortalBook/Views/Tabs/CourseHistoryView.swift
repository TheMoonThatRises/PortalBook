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

    @State var selectedCourse: StudentVueScraper.CourseData?

    var body: some View {
        NavigationStack {
            if let courseHistory = courseHistory?.courseHistory {
                ScrollView {
                    ForEach(courseHistory) { history in
                        DisclosureGroup {
                            ForEach(history.terms) { term in
                                DisclosureGroup {
                                    Grid {
                                        GridRow {
                                            Text("Course Name")
                                            Spacer()
                                            Text("Mark")
                                        }
                                        .bold()
                                        ForEach(term.courses) { course in
                                            Divider()
                                            GridRow {
                                                Text(course.courseTitle)
                                                Spacer()
                                                Text(course.mark)
                                            }
                                            .onTapGesture {
                                                selectedCourse = course
                                            }
                                        }
                                    }
                                } label: {
                                    Text("\(term.schoolName) \(term.year) \(term.termName)")
                                        .foregroundStyle(Color.accentColor)
                                        .padding()
                                }
                            }
                        } label: {
                            Text("Grade \(history.grade)")
                                .bold()
                                .font(.title)
                                .foregroundStyle(Color.primary)
                                .padding()
                        }
                    }
                }
            } else if loadingMessage == .empty {
                Text("Unable to load course history")
            }
        }
        .frame(alignment: .topLeading)
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
                    courseHistory = try await client.scraper.getCourseHistory()
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
        .sheet(item: $selectedCourse) { selected in
            DetailedCourseView(course: selected)
        }
    }
}

struct DetailedCourseView: View {
    @Environment(\.dismiss) var dismiss

    var course: StudentVueScraper.CourseData

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Course ID")
                    Spacer()
                    Text(course.courseID)
                }
                Divider()
                GridRow {
                    Text("Credits Attempted")
                    Spacer()
                    Text(course.creditsAttempted)
                }
                Divider()
                GridRow {
                    Text("Credits Completed")
                    Spacer()
                    Text(course.creditsCompleted)
                }
                Divider()
                GridRow {
                    Text("Verified Credit")
                    Spacer()
                    Text(course.verifiedCredit)
                }
                Divider()
                GridRow {
                    Text("Mark")
                    Spacer()
                    Text(course.mark)
                }
                Divider()
                GridRow {
                    Text("CHS Type")
                    Spacer()
                    Text(course.chsType)
                }
            }
            .padding()
            .navigationTitle(course.courseTitle)
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
