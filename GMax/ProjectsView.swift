import SwiftUI

// MARK: - Projects View
struct ProjectsView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var showingAddProject = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Main project header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.mainProject.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(viewModel.mainProject.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding()
                
                // Sub-projects list
                List {
                    ForEach(viewModel.mainProject.subProjects) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)) {
                            ProjectRowView(project: project)
                        }
                    }
                    .onDelete(perform: deleteProject)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("Projects", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showingAddProject = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
                    .environmentObject(viewModel)
            }
        }
    }
    
    func deleteProject(at offsets: IndexSet) {
        // Remove the projects at the specified indices
        viewModel.mainProject.subProjects.remove(atOffsets: offsets)
        viewModel.saveMainProject()
    }
}

struct ProjectRowView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(project.title)
                    .font(.headline)
                
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
                .lineLimit(2)
            
            HStack {
                Text("\(project.entries.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Updated \(project.updatedAt, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}