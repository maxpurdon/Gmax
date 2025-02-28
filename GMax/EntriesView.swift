//
//  EntriesView 2.swift
//  GMax
//
//  Created by Andrew Purdon on 28/02/2025.
//


import SwiftUI

// MARK: - Entries View
struct EntriesView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var viewMode: ViewMode = .timeline
    @State private var searchText = ""
    
    enum ViewMode {
        case timeline, list, grid
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                Picker("View Mode", selection: $viewMode) {
                    Image(systemName: "clock").tag(ViewMode.timeline)
                    Image(systemName: "list.bullet").tag(ViewMode.list)
                    Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // All entries across all projects
                let allEntries = viewModel.mainProject.subProjects.flatMap { $0.entries }
                
                switch viewMode {
                case .timeline:
                    TimelineView(entries: filteredEntries(from: allEntries))
                case .list:
                    ListView(entries: filteredEntries(from: allEntries))
                case .grid:
                    GridView(entries: filteredEntries(from: allEntries))
                }
            }
            .navigationBarTitle("All Entries", displayMode: .inline)
        }
    }
    
    private func filteredEntries(from entries: [Entry]) -> [Entry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.title.lowercased().contains(searchText.lowercased()) ||
                entry.content.lowercased().contains(searchText.lowercased()) ||
                entry.tags.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
}