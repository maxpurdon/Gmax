import SwiftUI

struct TimelineView: View {
    let entries: [Entry]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(entriesByDate.keys.sorted().reversed(), id: \.self) { date in
                    if let dayEntries = entriesByDate[date] {
                        Section(header:
                            Text(date, formatter: dateFormatter)
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                        ) {
                            VStack(spacing: 1) {
                                ForEach(dayEntries) { entry in
                                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                                        EntrySummaryRow(entry: entry)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                        }
                    }
                }
            }
            .padding(.bottom, 80) // Space for FAB
        }
    }
    
    private var entriesByDate: [Date: [Entry]] {
        let calendar = Calendar.current
        
        var result = [Date: [Entry]]()
        for entry in entries {
            let date = calendar.startOfDay(for: entry.createdAt)
            if result[date] == nil {
                result[date] = [entry]
            } else {
                result[date]?.append(entry)
            }
        }
        
        return result
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct ListView: View {
    let entries: [Entry]
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, placeholder: "Search entries...")
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
            
            List {
                ForEach(filteredEntries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                        EntrySummaryRow(entry: entry)
                            .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private var filteredEntries: [Entry] {
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

struct GridView: View {
    let entries: [Entry]
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(entries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                        EntryCard(entry: entry)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
            .padding(.bottom, 80) // Space for FAB
        }
    }
}

struct EntrySummaryRow: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let location = entry.location {
                    LocationBadge(locationName: location.name)
                }
            }
            
            Text(entry.content)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.tags.prefix(3), id: \.self) { tag in
                                TagView(tag: tag)
                            }
                            
                            if entry.tags.count > 3 {
                                Text("+\(entry.tags.count - 3)")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 22)
                }
                
                Spacer()
                
                // Time
                Text(formatTime(entry.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Media thumbnails
            if !entry.media.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.media.prefix(3)) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                    }
                    
                    if entry.media.count > 3 {
                        Text("+\(entry.media.count - 3)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EntryCard: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Media preview
            if !entry.media.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .cornerRadius(8)
            }
            
            Text(entry.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(entry.content)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack {
                if !entry.tags.isEmpty {
                    TagView(tag: entry.tags[0])
                    
                    if entry.tags.count > 1 {
                        Text("+\(entry.tags.count - 1)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(formatDate(entry.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct TagView: View {
    let tag: String
    
    var body: some View {
        Text("#\(tag)")
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
}

struct LocationBadge: View {
    let locationName: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin")
                .font(.system(size: 10))
            
            Text(locationName)
                .font(.system(size: 11, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .foregroundColor(.secondary)
        .cornerRadius(4)
    }
}
