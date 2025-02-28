import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

// MARK: - View Models
class ProjectViewModel: ObservableObject {
    @Published var mainProject = MainProject.sample
    @Published var templates = EntryTemplate.samples
    @Published var locations = Location.samples
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    // MARK: - Firebase operations
    
    func loadMainProject() {
        // In a real app, fetch from Firebase
        db.collection("projects").document("mainProject").getDocument { (document, error) in
            if let document = document, document.exists, let data = try? document.data(as: MainProject.self) {
                DispatchQueue.main.async {
                    self.mainProject = data
                }
            } else {
                // For now, using sample data if no data exists
                print("No data found, using sample data")
            }
        }
    }
    
    func saveMainProject() {
        do {
            try db.collection("projects").document("mainProject").setData(from: mainProject)
            print("Main project saved to Firebase")
        } catch {
            print("Error saving main project: \(error.localizedDescription)")
        }
    }
    
    func saveProject(_ project: Project, in mainProject: MainProject) {
        if let index = mainProject.subProjects.firstIndex(where: { $0.id == project.id }) {
            self.mainProject.subProjects[index] = project
            saveMainProject()
        }
    }
    
    func uploadMedia(image: UIImage, completion: @escaping (Result<EntryMedia, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let filename = UUID().uuidString
        let storageRef = storage.reference().child("images/\(filename).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                // Create thumbnail (in a real app, generate an actual thumbnail)
                let thumbnailRef = storageRef.parent()?.child("thumbnails/\(filename)_thumb.jpg")
                thumbnailRef?.downloadURL { thumbURL, _ in
                    let media = EntryMedia(
                        type: .image,
                        url: downloadURL.absoluteString,
                        thumbnailUrl: thumbURL?.absoluteString,
                        createdAt: Date()
                    )
                    completion(.success(media))
                }
            }
        }
    }
    
    // MARK: - Template management
    
    func addTemplate(_ template: EntryTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    func updateTemplate(_ template: EntryTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: EntryTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    private func saveTemplates() {
        // In a real app, save to Firebase or UserDefaults
        do {
            try db.collection("templates").document("userTemplates").setData(from: templates)
        } catch {
            print("Error saving templates: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Location management
    
    func addLocation(_ location: Location) {
        locations.append(location)
        saveLocations()
    }
    
    func deleteLocation(_ location: Location) {
        locations.removeAll { $0.id == location.id }
        saveLocations()
    }
    
    private func saveLocations() {
        // In a real app, save to Firebase or UserDefaults
        do {
            try db.collection("settings").document("locations").setData(from: locations)
        } catch {
            print("Error saving locations: \(error.localizedDescription)")
        }
    }
    
    // MARK: - PDF Export
    
    func exportEntryAsPDF(_ entry: Entry, completion: @escaping (Result<URL, Error>) -> Void) {
        // For a real implementation, use PDFKit to create a PDF
        // This is a placeholder that would be implemented later
        
        /* PDFKit implementation would go here */
        
        // Return a success for the prototype
        completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "PDF export not implemented in prototype"])))
    }
}