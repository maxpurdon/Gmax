//
//  AddMilestoneToProjectView.swift
//  GMax
//
//  Created by Andrew Purdon on 28/02/2025.
//


import SwiftUI

struct AddMilestoneToProjectView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(86400 * 7) // Default to 1 week from now
    @State private var selectedProjectId: String? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Milestone Information")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section(header: Text("Project")) {
                    Picker("Select Project", selection: $selectedProjectId) {
                        Text("None").tag(String?.none)
                        ForEach(viewModel.mainProject.subProjects) { project in
                            Text(project.title).tag(Optional(project.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationBarTitle("New Milestone", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveMilestone()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || selectedProjectId == nil)
            )
        }
    }
    
    private func saveMilestone() {
        guard let projectId = selectedProjectId else { return }
        
        let newMilestone = Milestone(
            title: title,
            description: description,
            dueDate: dueDate,
            isCompleted: false
        )
        
        // Find the project and add the milestone
        if let projectIndex = viewModel.mainProject.subProjects.firstIndex(where: { $0.id == projectId }) {
            viewModel.mainProject.subProjects[projectIndex].milestones.append(newMilestone)
            viewModel.mainProject.subProjects[projectIndex].updatedAt = Date()
            viewModel.saveMainProject()
        }
    }
}