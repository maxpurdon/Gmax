import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var showingAddTemplate = false
    @State private var showingAddLocation = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Templates")) {
                    ForEach(viewModel.templates) { template in
                        NavigationLink(destination: TemplateDetailView(template: template)) {
                            Text(template.name)
                        }
                    }
                    .onDelete(perform: deleteTemplate)
                    
                    Button(action: {
                        showingAddTemplate = true
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
                    .onDelete(perform: deleteLocation)
                    
                    Button(action: {
                        showingAddLocation = true
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
            .sheet(isPresented: $showingAddTemplate) {
                AddTemplateView()
                    .environmentObject(viewModel)
            }
            .alert(isPresented: $showingAddLocation) {
                var textField: UITextField?
                
                return Alert(
                    title: Text("Add Location"),
                    message: Text("Enter a name for the new location"),
                    primaryButton: .default(Text("Add")) {
                        if let locationName = textField?.text, !locationName.isEmpty {
                            let newLocation = Location(name: locationName)
                            viewModel.addLocation(newLocation)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func deleteTemplate(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTemplate(viewModel.templates[index])
        }
    }
    
    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteLocation(viewModel.locations[index])
        }
    }
}

struct TemplateDetailView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var template: EntryTemplate
    @State private var isEditing = false
    
    init(template: EntryTemplate) {
        _template = State(initialValue: template)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                EditTemplateView(template: $template)
            } else {
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
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            if isEditing {
                // Save changes
                viewModel.updateTemplate(template)
            }
            isEditing.toggle()
        }) {
            Text(isEditing ? "Save" : "Edit")
        })
        .onChange(of: isEditing) { editing in
            if !editing {
                // Refresh template from ViewModel when exiting edit mode
                if let updatedTemplate = viewModel.templates.first(where: { $0.id == template.id }) {
                    template = updatedTemplate
                }
            }
        }
    }
}

struct EditTemplateView: View {
    @Binding var template: EntryTemplate
    
    @State private var name: String
    @State private var contentTemplate: String
    @State private var defaultTags: String
    
    init(template: Binding<EntryTemplate>) {
        self._template = template
        self._name = State(initialValue: template.wrappedValue.name)
        self._contentTemplate = State(initialValue: template.wrappedValue.contentTemplate)
        self._defaultTags = State(initialValue: template.wrappedValue.defaultTags.joined(separator: ", "))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Template Name", text: $name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Template Content:")
                .font(.headline)
            
            TextEditor(text: $contentTemplate)
                .font(.body)
                .frame(minHeight: 150)
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Text("Default Tags (comma separated):")
                .font(.headline)
            
            TextField("Tags", text: $defaultTags)
                .font(.body)
                .onChange(of: name) { _ in updateTemplate() }
                .onChange(of: contentTemplate) { _ in updateTemplate() }
                .onChange(of: defaultTags) { _ in updateTemplate() }
        }
    }
    
    private func updateTemplate() {
        template.name = name
        template.contentTemplate = contentTemplate
        template.defaultTags = defaultTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

struct AddTemplateView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var contentTemplate = ""
    @State private var defaultTags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Information")) {
                    TextField("Name", text: $name)
                    
                    ZStack(alignment: .topLeading) {
                        if contentTemplate.isEmpty {
                            Text("Content Template")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $contentTemplate)
                            .frame(minHeight: 150)
                    }
                    
                    TextField("Default Tags (comma separated)", text: $defaultTags)
                }
            }
            .navigationBarTitle("New Template", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let tagArray = defaultTags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    
                    let newTemplate = EntryTemplate(
                        name: name,
                        contentTemplate: contentTemplate,
                        defaultTags: tagArray
                    )
                    
                    viewModel.addTemplate(newTemplate)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}
