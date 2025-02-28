import SwiftUI

struct EntriesView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var viewMode: ViewMode = .timeline
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var showingTagSelector = false
    
    enum ViewMode {
        case timeline, list, grid
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filter
            VStack(spacing: 16) {
                Text("Journal Entries")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    SearchBar(text: $searchText, placeholder: "Search entries...")
                    
                    Button(action: {
                        showingTagSelector = true
                    }) {
                        HStack {
                            Image(systemName: "tag")
                            if let tag = selectedTag {
                                Text(tag)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // View mode selector
            Picker("View Mode", selection: $viewMode) {
                Image(systemName: "clock").tag(ViewMode.timeline)
                Image(systemName: "list.bullet").tag(ViewMode.list)
                Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Content view
            switch viewMode {
            case .timeline:
                TimelineView(entries: filteredEntries)
            case .list:
                ListView(entries: filteredEntries)
            case .grid:
                GridView(entries: filteredEntries)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .actionSheet(isPresented: $showingTagSelector) {
            ActionSheet(
                title: Text("Filter by Tag"),
                message: nil,
                buttons: tagFilterButtons
            )
        }
    }
    
    private var tagFilterButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = [
            .default(Text("All Entries")) {
                selectedTag = nil
            }
        ]
        
        // Collect unique tags across all entries
        let allTags = Set(viewModel.mainProject.subProjects.flatMap { $0.entries.flatMap { $0.tags } })
        
        // Add a button for each unique tag
        for tag in allTags.sorted() {
            buttons.append(
                .default(Text("#\(tag)")) {
                    selectedTag = tag
                }
            )
        }
        
        buttons.append(.cancel())
        
        return buttons
    }
    
    private var allEntries: [Entry] {
        viewModel.mainProject.subProjects.flatMap { $0.entries }
    }
    
    private var filteredEntries: [Entry] {
        var entries = allEntries
        
        // Apply tag filter if selected
        if let tag = selectedTag {
            entries = entries.filter { $0.tags.contains(tag) }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.title.lowercased().contains(searchText.lowercased()) ||
                entry.content.lowercased().contains(searchText.lowercased()) ||
                entry.tags.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
        
        // Sort by created date, newest first
        return entries.sorted { $0.createdAt > $1.createdAt }
    }
}
