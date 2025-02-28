//
//  ImagePicker 2.swift
//  GMax
//
//  Created by Andrew Purdon on 28/02/2025.
//


import SwiftUI

// MARK: - Utility Views

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct HeatmapView: View {
    let entries: [Entry]
    let months = 6
    let daysPerWeek = 7
    
    private var entriesPerDay: [Date: Int] {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -months * 30, to: now)!
        
        var result = [Date: Int]()
        for entry in entries {
            if entry.createdAt >= start {
                let day = calendar.startOfDay(for: entry.createdAt)
                result[day, default: 0] += 1
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Heatmap")
                .font(.headline)
            
            // Placeholder for actual heatmap
            Text("Heatmap Visualization (Placeholder)")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // This would be replaced with a real implementation
            // that shows a grid of cells colored based on activity level
            
            Text("Placeholder - In a complete implementation, this would show a calendar-style heatmap grid where each cell represents a day, colored based on activity level.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct PDFPreview: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        // In a complete implementation, this would use PDFKit to display
        // a preview of the PDF
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update view if needed
    }
}
