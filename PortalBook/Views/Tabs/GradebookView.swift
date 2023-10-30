//
//  GradebookView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/26/23.
//

import SwiftUI
import AlertToast
import StudentVue
import Charts

struct GradebookView: View {
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var gradebook: StudentVueApi.GradeBook? {
        didSet {
            gradebook == nil ? refresh.toggle() : nil
        }
    }

    var body: some View {
        NavigationStack {
            if let gradebook = gradebook {
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
                                HStack {
                                    Text(gradingPeriod.gradePeriodName)
                                    Text("-")
                                    Text(gradingPeriod.calculatedGrade)
                                        .font(.body)
                                    Text("(\(String(format: "%.2f", gradingPeriod.calculatedGradeRaw))%)")
                                        .font(.subheadline)
                                    Spacer()
//                                    Text("\(course.missingAssignments) missing assignments")
//                                        .font(.caption)
//                                        .foregroundColor(course.missingAssignments > 0 ? .red : nil)
                                }
                            }
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Gradebook")
        .toolbar {
            ToolbarItem {
                Button {
                    gradebook = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { gradebook == nil ? gradebook = nil : nil }
        .onChange(of: refresh) {
            Task {
                defer {
                    loadingMessage = .empty
                }

                loadingMessage = .loadingGrades

                do {
                    gradebook = try await client.api.getGradeBook()
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
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
                                Text(grade.score)
                            }
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
        .onAppear {
            print(course)
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
            Text(assignment.measureDescription)
                .font(.caption)
                .padding()
            Grid {
                GridRow {
                    Text("Assigned Date")
                    Spacer()
                    Text(assignment.date, format: .dateTime)
                }
                Divider()
                GridRow {
                    Text("Due Date")
                    Spacer()
                    Text(assignment.dueDate, format: .dateTime)
                }
                Divider()
                GridRow {
                    Text("Type")
                    Spacer()
                    Text(assignment.type)
                }
                Divider()
                GridRow {
                    Text("Score")
                    Spacer()
                    Text(assignment.score)
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
                    Text(resource.resourceDate, format: .dateTime)
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
                Divider()
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
