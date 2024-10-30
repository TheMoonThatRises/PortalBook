//
//  GradebookView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/26/23.
//

import SwiftUI
import AlertToast
import StudentVue

struct GradebookView: View {
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false

    var body: some View {
        NavigationStack {
            if let gradebook = dataCache.gradeBook {
                List(gradebook.courses, id: \.period) { course in
                    NavigationLink {
                        ClassView(course: course)
                    } label: {
                        VStack {
                            HStack {
                                Text("\(course.period): \(course.name)")
                                    .font(.title3)
                                Spacer()
                                Text("\(course.room): \(course.teacher)")
                                    .font(.callout)
                            }
                            Spacer()
                            if let gradingPeriod = course.grades.first {
                                let missingAssignments = gradingPeriod.assignments.filter { $0.isMissing }.count
                                let isPlural = missingAssignments == 1 ? "" : "s"

                                HStack {
                                    Text(gradingPeriod.gradePeriodName)
                                    Text("-")
                                    Text(gradingPeriod.calculatedGrade)
                                        .font(.body)
                                    Text("(\(String(format: "%.2f", gradingPeriod.calculatedGradeRaw))%)")
                                        .font(.subheadline)
                                    Spacer()
                                    if missingAssignments > 0 {
                                        Text("\(missingAssignments) missing assignment\(isPlural)")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                }
                .refreshable {
                    refresh.toggle()
                }
            } else if loadingMessage == .empty {
                Text("Unable to load gradebook")
            }
        }
        .navigationTitle("Gradebook")
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
            if !dataCache.gradeBookLoaded {
                loadingMessage = .loadingGrades
            }
        }
        .onChange(of: dataCache.gradeBookLoaded) {
            loadingMessage = dataCache.gradeBookLoaded ? .empty : .loadingGrades
        }
        .onChange(of: refresh) {
            do {
                try dataCache.reloadGradeBook(client: client, force: true)
            } catch {
                print("error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ClassView: View {
    var course: StudentVueApi.Course

    @State var selectedAssignment: StudentVueApi.GradeBookAssignment?

    var body: some View {
        NavigationView {
            List(course.grades, id: \.gradePeriodName) { period in
                DisclosureGroup {
                    HStack {
                        Text("Assignment Name")
                        Spacer()
                        Text("Score")
                    }
                    .bold()
                    ForEach(period.assignments) { grade in
                        Button {
                            selectedAssignment = grade
                        } label: {
                            HStack {
                                Text(grade.measure)
                                Spacer()
                                Text(grade.points)
                            }
                            .foregroundStyle(grade.isMissing ? .red : .blue)
                        }
                    }
                } label: {
                    Text(
                        String(
                            format: "%@: %@ (%.2f%%), Assignments: %d",
                            period.gradePeriodName, period.calculatedGrade,
                            period.calculatedGradeRaw, period.assignments.count
                        )
                    )
                }
            }
        }
        .navigationTitle(course.name)
        .sheet(item: $selectedAssignment) { item in
            DetailedGradeView(assignment: item)
        }
    }
}

struct DetailedGradeView: View {
    @Environment(\.dismiss) var dismiss

    var assignment: StudentVueApi.GradeBookAssignment

    @State var selectedResource: StudentVueApi.GradeBookResource?

    var body: some View {
        NavigationStack {
            Text(assignment.measureDescription.stringByDecodingHTMLEntities)
                .font(.caption)
                .padding()
            Grid {
                GridRow {
                    Text("Assigned Date")
                    Spacer()
                    Text(assignment.date.formatted())
                }
                Divider()
                GridRow {
                    Text("Due Date")
                    Spacer()
                    Text(assignment.dueDate.formatted())
                }
                Divider()
                GridRow {
                    Text("Type")
                    Spacer()
                    Text(assignment.type)
                }
                Divider()
                GridRow {
                    Text("Score Type")
                    Spacer()
                    Text(assignment.scoreType)
                }
                Divider()
                GridRow {
                    Text("Points")
                    Spacer()
                    Text(assignment.points)
                }
                Divider()
                GridRow {
                    Text("Last Updated")
                    Spacer()
                    Text(
                        Date(timeIntervalSince1970: Date().timeIntervalSince1970 - assignment.totalSecondsSincePost
                        ).formatted()
                    )
                }
                Divider()
                if assignment.resources.count > 0 {
                    DisclosureGroup("Resources") {
                        Text("Resource Name")
                            .bold()
                        ForEach(assignment.resources) { resource in
                            Divider()
                            Button {
                                selectedResource = resource
                            } label: {
                                Text(resource.resourceName)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle(assignment.measure)
            .toolbar {
                ToolbarItem {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedResource) { item in
            DetailedResourceView(resource: item)
        }
    }
}

struct DetailedResourceView: View {
    @Environment(\.dismiss) var dismiss

    var resource: StudentVueApi.GradeBookResource

    var body: some View {
        NavigationStack {
            Text(resource.resourceDescription)
                .font(.caption)
                .padding()
            Grid {
                GridRow {
                    Text("Type")
                    Spacer()
                    Text(resource.type)
                }
                Divider()
                GridRow {
                    Text("File Type")
                    Spacer()
                    Text(resource.fileType ?? "Unknown")
                }
                Divider()
                GridRow {
                    Text("Resource Date")
                    Spacer()
                    Text(resource.resourceDate.formatted())
                }
                Divider()
                GridRow {
                    Text("Link")
                    Spacer()
                    if let link = resource.url {
                        Text(.init("[\(link)](\(link))"))
                    } else {
                        Text("None")
                    }
                }
            }
            .padding()
            .navigationTitle(resource.resourceName)
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
