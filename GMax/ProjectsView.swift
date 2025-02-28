import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var showingAddProject = false
    @State private var searchText = ""
    
    private var filteredProjects: [Project] {
        if searchText.isEmpty {
            return viewModel.mainProject.subProjects
        } else {
            return viewModel.mainProject.subProjects.filter { project in
                project.title.lowercased().contains(searchText.lowercased()) ||
                project.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header with search
                VStack(spacing: 16) {
                    Text(viewModel.mainProject.title)
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SearchBar(text: $searchText, placeholder: "Search projects...")
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color(.systemBackground))
                
                // Project grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                        ForEach(filteredProjects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectCardView(project: project)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80) // Space for FAB
                }
                .background(Color(.systemGroupedBackground))
            }
            
            // FAB
            Button(action: {
                showingAddProject = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .padding(.bottom, 16)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            // Edit main project (title/description)
        }) {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
        })
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
                .environmentObject(viewModel)
        }
    }
}

struct ProjectCardView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status indicator
            HStack {
                Circle()
                    .fill(project.status.color)
                    .frame(width: 8, height: 8)
                
                Text(project.status.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(project.entries.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Title and description
            Text(project.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(project.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Updated date
            Text("Updated \(formatDate(project.updatedAt))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(height: 150)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
