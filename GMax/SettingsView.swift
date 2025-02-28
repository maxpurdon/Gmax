// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Templates")) {
                    ForEach(viewModel.templates) { template in
                        NavigationLink(destination: TemplateDetailView(template: template)) {
                            Text(template.name)
                        }
                    }
                    
                    Button(action: {
                        // Add template
                        print("Add template (placeholder)")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Template")
                        }
                    }
                }
                
                Section(header: Text("Locations")) {
                    ForEach(viewModel.locations) { location in
                        Text(location.name)
                    }
                    
                    Button(action: {
                        // Add location
                        print("Add location (placeholder)")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Location")
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Account Settings (Placeholder)")) {
                        Text("Account Settings")
                    }
                    
                    NavigationLink(destination: Text("Data & Sync (Placeholder)")) {
                        Text("Data & Sync")
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Help (Placeholder)")) {
                        Text("Help")
                    }
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

struct TemplateDetailView: View {
    let template: EntryTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(template.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text("Template Content:")
                .font(.headline)
            
            Text(template.contentTemplate)
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            if !template.defaultTags.isEmpty {
                Text("Default Tags:")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(template.defaultTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            // Edit template
            print("Edit template (placeholder)")
        }) {
            Text("Edit")
        })
    }
}