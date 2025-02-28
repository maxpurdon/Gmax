import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProjectViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                ProjectsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(viewModel)
            .tabItem {
                Label("Projects", systemImage: "folder.fill")
            }
            
            NavigationView {
                EntriesView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(viewModel)
            .tabItem {
                Label("Journal", systemImage: "text.book.closed.fill")
            }
            
            NavigationView {
                MilestonesView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(viewModel)
            .tabItem {
                Label("Timeline", systemImage: "calendar")
            }
            
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(viewModel)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .accentColor(.blue)
        .onAppear {
            // Configure tab bar appearance
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
            
            // Load data
            viewModel.loadMainProject()
        }
    }
}
