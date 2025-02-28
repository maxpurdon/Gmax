import SwiftUI
import Foundation

// MARK: - Add Milestone View
struct AddMilestoneView: View {
    @Environment(\.presentationMode) var presentationMode
    var onSave: (Milestone) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(86400 * 7) // Default to 1 week from now
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Milestone Information")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationBarTitle("New Milestone", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newMilestone = Milestone(
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        isCompleted: false
                    )
                    
                    onSave(newMilestone)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}
