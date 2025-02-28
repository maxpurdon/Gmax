// MARK: - Add Entry View
import Foundation
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
    @State private var recordedText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template")) {
                    Picker("Template", selection: $selectedTemplateId) {
                        Text("None").tag(String?.none)
                        ForEach(viewModel.templates) { template in
                            Text(template.name).tag(Optional(template.id))
                        }
                    }
                    .onChange(of: selectedTemplateId) { newValue in
                        if let templateId = newValue,
                           let template = viewModel.templates.first(where: { $0.id == templateId }) {
                            content = template.contentTemplate
                            tags = template.defaultTags.joined(separator: ", ")
                        }
                    }
                }
                
                Section(header: Text("Entry Information")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Content")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    }
                    
                    TextField("Tags (comma separated)", text: $tags)
                    
                    Picker("Location", selection: $selectedLocation) {
                        Text("None").tag(Location?.none)
                        ForEach(viewModel.locations) { location in
                            Text(location.name).tag(Optional(location))
                        }
                    }
                }
                
                Section(header: Text("Media")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add Photo")
                        }
                    }
                    
                    Button(action: {
                        // Voice-to-text functionality (placeholder)
                        isRecording.toggle()
                        
                        if isRecording {
                            // Start recording (placeholder)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isRecording = false
                                recordedText = "This is placeholder voice-to-text content."
                                content += "\n\n" + recordedText
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                .foregroundColor(isRecording ? .red : .primary)
                            Text(isRecording ? "Recording..." : "Voice to Text")
                        }
                    }
                    
                    if !mediaItems.isEmpty {
                        ForEach(mediaItems.indices, id: \.self) { index in
                            HStack {
                                Text("Media \(index + 1)")
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
            .navigationBarTitle("New Entry", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
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
                .disabled(title.isEmpty)
            )
            .sheet(isPresented: $showingMilestoneSheet) {
                AddMilestoneView { newMilestone in
                    milestones.append(newMilestone)
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        // Upload to Firebase Storage (placeholder)
        viewModel.uploadMedia(image: inputImage) { result in
            switch result {
            case .success(let media):
                mediaItems.append(media)
            case .failure(let error):
                print("Failed to upload image: \(error.localizedDescription)")
            }
        }
    }
}
