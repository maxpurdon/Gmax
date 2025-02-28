import SwiftUI

// MARK: - Main Views
struct ContentView: View {
    @StateObject private var viewModel = ProjectViewModel()
    
    var body: some View {
        TabView {
            ProjectsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
            
            EntriesView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Entries", systemImage: "note.text")
                }
            
            MilestonesView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Milestones", systemImage: "calendar")
                }
            
            SettingsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            viewModel.loadMainProject()
        }
    }
}