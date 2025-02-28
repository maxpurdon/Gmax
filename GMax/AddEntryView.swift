import SwiftUI

struct AddEntryView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    let projectId: String
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedTemplateId: String? = nil
    @State private var selectedLocation: Location? = nil
    @State private var tags = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = nil
    @State private var mediaItems: [EntryMedia] = []
    @State private var isRecording = false
    
    // Simplified UI with sections
    var body: some View {
        NavigationView {
            Form {
                // Template picker
                Section(header: Text("Template").font(.subheadline)) {
                    Picker("Select Template", selection: $selectedTemplateId) {
                        Text("None").tag(String?.none)
                        ForEach(viewModel.templates) { template in
                            Text(template.name).tag(Optional(template.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedTemplateId) { newValue in
                        if let templateId = newValue,
                           let template = viewModel.templates.first(where: { $0.id == templateId }) {
                            content = template.contentTemplate
                            tags = template.defaultTags.joined(separator: ", ")
                        }
                    }
                }
                
                // Entry content
                Section(header: Text("Entry Details").font(.subheadline)) {
                    TextField("Title", text: $title)
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Write your notes here...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .padding(.horizontal, -5)
                    }
                }
                
                // Tags & location
                Section(header: Text("Organization").font(.subheadline)) {
                    TextField("Tags (comma separated)", text: $tags)
                    
                    Picker("Location", selection: $selectedLocation) {
                        Text("None").tag(Location?.none)
                        ForEach(viewModel.locations) { location in
                            Text(location.name).tag(Optional(location))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Media
                Section(header: Text("Media").font(.subheadline)) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                            Text("Add Photo")
                        }
                    }
                    
                    Button(action: {
                        // Voice-to-text functionality
                        isRecording.toggle()
                        
                        if isRecording {
                            // Start recording (placeholder)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isRecording = false
                                let recordedText = "This is placeholder voice-to-text content."
                                content += "\n\n" + recordedText
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                .foregroundColor(isRecording ? .red : .blue)
                            Text(isRecording ? "Recording..." : "Voice to Text")
                        }
                    }
                    
                    if !mediaItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Added Media")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(mediaItems.indices, id: \.self) { index in
                                HStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                    
                                    Text("Media \(index + 1)")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        mediaItems.remove(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("New Entry", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveEntry()
                }
                .disabled(title.isEmpty)
            )
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                            ImagePicker(image: $inputImage)
                        }
                    }
                }
                
                // Simplified save function
                private func saveEntry() {
                    let tagArray = tags
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    
                    let newEntry = Entry(
                        title: title,
                        content: content,
                        media: mediaItems,
                        location: selectedLocation,
                        tags: tagArray,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    
                    if let index = viewModel.mainProject.subProjects.firstIndex(where: { $0.id == projectId }) {
                        viewModel.mainProject.subProjects[index].entries.append(newEntry)
                        viewModel.mainProject.subProjects[index].updatedAt = Date()
                        viewModel.saveProject(viewModel.mainProject.subProjects[index], in: viewModel.mainProject)
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }
                
                func loadImage() {
                    guard let inputImage = inputImage else { return }
                    
                    // Show loading indicator
                    let loadingMedia = EntryMedia(
                        type: .image,
                        url: "placeholder_uploading",
                        thumbnailUrl: nil,
                        createdAt: Date()
                    )
                    mediaItems.append(loadingMedia)
                    
                    // Upload to Firebase Storage
                    viewModel.uploadMedia(image: inputImage) { result in
                        // Remove loading placeholder
                        if let index = mediaItems.firstIndex(where: { $0.url == "placeholder_uploading" }) {
                            mediaItems.remove(at: index)
                        }
                        
                        switch result {
                        case .success(let media):
                            mediaItems.append(media)
                        case .failure(let error):
                            print("Failed to upload image: \(error.localizedDescription)")
                            // Could show an alert here
                        }
                    }
                }
            }
