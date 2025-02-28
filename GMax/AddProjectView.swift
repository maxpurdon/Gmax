// MARK: - Add Project View
import Foundation
import SwiftUI
import 

struct AddProjectView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var status = ProjectStatus.concept   
    @State private var showingMilestoneSheet = false
    @State private var milestones: [Milestone] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Information")) {
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
                    
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section(header: Text("Initial Milestones")) {
                    ForEach(milestones) { milestone in
                        VStack(alignment: .leading) {
                            Text(milestone.title)
                                .font(.headline)
                            
                            Text(milestone.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(milestone.dueDate, formatter: dateFormatter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteMilestone)
                    
                    Button(action: {
                        showingMilestoneSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Milestone")
                        }
                    }
                }
            }
            .navigationBarTitle("New Project", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newProject = Project(
                        title: title,
                        description: description,
                        status: status,
                        createdAt: Date(),
                        updatedAt: Date(),
                        entries: [],
                        milestones: milestones
                    )
                    
                    viewModel.mainProject.subProjects.append(newProject)
                    viewModel.saveMainProject()
                    presentationMode.wrappedValue.dismiss()
                }
                    .disabled(title.isEmpty)
            )
        }
    }
}
