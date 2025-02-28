import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var project: Project
    @State private var viewMode: ViewMode = .timeline
    @State private var showingAddEntry = false
    @State private var showingEditProject = false
    
    enum ViewMode {
        case timeline, list, grid
    }
    
    init(project: Project) {
        _project = State(initialValue: project)
    }
    
    var body: some View {
        VStack {
            // Project header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(project.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(project.status.rawValue)
                        .font(.caption)
                        .padding(4)
                        .background(project.status.color)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Text(project.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            
            // View mode selector
            Picker("View Mode", selection: $viewMode) {
                Image(systemName: "clock").tag(ViewMode.timeline)
                Image(systemName: "list.bullet").tag(ViewMode.list)
                Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Entries
            switch viewMode {
            case .timeline:
                TimelineView(entries: project.entries)
            case .list:
                ListView(entries: project.entries)
            case .grid:
                GridView(entries: project.entries)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading: Button(action: {
                showingEditProject = true
            }) {
                Text("Edit")
            },
            trailing: Button(action: {
                showingAddEntry = true
            }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(projectId: project.id)
                .environmentObject(viewModel)
                .onDisappear {
                    // Update project when AddEntryView is dismissed
                    if let updatedProject = viewModel.mainProject.subProjects.first(where: { $0.id == project.id }) {
                        project = updatedProject
                    }
                }
        }
        .sheet(isPresented: $showingEditProject) {
            EditProjectView(project: $project)
                .environmentObject(viewModel)
                .onDisappear {
                    // Update the project in the ViewModel when EditProjectView is dismissed
                    if let index = viewModel.mainProject.subProjects.firstIndex(where: { $0.id == project.id }) {
                        viewModel.mainProject.subProjects[index] = project
                        viewModel.saveMainProject()
                    }
                }
        }
    }
}

struct EditProjectView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var project: Project
    
    @State private var title: String
    @State private var description: String
    @State private var status: ProjectStatus
    
    init(project: Binding<Project>) {
        self._project = project
        self._title = State(initialValue: project.wrappedValue.title)
        self._description = State(initialValue: project.wrappedValue.description)
        self._status = State(initialValue: project.wrappedValue.status)
    }
    
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
            }
            .navigationBarTitle("Edit Project", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    project.title = title
                    project.description = description
                    project.status = status
                    project.updatedAt = Date()
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}
