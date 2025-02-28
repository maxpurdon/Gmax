import SwiftUI

struct EntryDetailView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var entry: Entry
    @State private var showingEditSheet = false
    @State private var showingExportOptions = false
    @State private var exportError: String? = nil
    
    init(entry: Entry) {
        _entry = State(initialValue: entry)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        if let location = entry.location {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin")
                                    .font(.caption)
                                
                                Text(location.name)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(entry.createdAt, formatter: dateFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Content
                Text(entry.content)
                    .font(.body)
                
                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(entry.tags, id: \.self) { tag in
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
                
                // Media
                if !entry.media.isEmpty {
                    Text("Media")
                        .font(.headline)
                        .padding(.top)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                        ForEach(entry.media) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            trailing: HStack {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Edit")
                }
                
                Button(action: {
                    showingExportOptions = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        )
        .sheet(isPresented: $showingEditSheet) {
            EditEntryView(entry: $entry)
                .environmentObject(viewModel)
        }
        .actionSheet(isPresented: $showingExportOptions) {
            ActionSheet(
                title: Text("Export Options"),
                message: Text("Choose an export format"),
                buttons: [
                    .default(Text("Export as PDF")) {
                        exportAsPDF()
                    },
                    .cancel()
                ]
            )
        }
        .alert(item: Binding<ExportError?>(
            get: { exportError != nil ? ExportError(message: exportError!) : nil },
            set: { exportError = $0?.message }
        )) { error in
            Alert(title: Text("Export Failed"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func exportAsPDF() {
        viewModel.exportEntryAsPDF(entry) { result in
            switch result {
            case .success(let url):
                // Share the PDF
                print("PDF created at: \(url)")
            case .failure(let error):
                exportError = error.localizedDescription
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    struct ExportError: Identifiable {
        let id = UUID()
        let message: String
    }
}

struct EditEntryView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var entry: Entry
    
    @State private var title: String
    @State private var content: String
    @State private var selectedLocation: Location?
    @State private var tags: String
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = nil
    @State private var isRecording = false
    
    init