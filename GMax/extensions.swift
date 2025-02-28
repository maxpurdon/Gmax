import SwiftUI

// MARK: - Extensions

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Date {
    func formattedString(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
}

extension Color {
    static let customBackground = Color(.systemBackground)
    static let customGroupedBackground = Color(.systemGroupedBackground)
    static let customSecondaryBackground = Color(.secondarySystemBackground)
    static let customTertiaryBackground = Color(.tertiarySystemBackground)
    
    static let customText = Color(.label)
    static let customSecondaryText = Color(.secondaryLabel)
    static let customTertiaryText = Color(.tertiaryLabel)
    static let customQuaternaryText = Color(.quaternaryLabel)
    
    static let customFill = Color(.systemFill)
    static let customSecondaryFill = Color(.secondarySystemFill)
    static let customTertiaryFill = Color(.tertiarySystemFill)
    static let customQuaternaryFill = Color(.quaternarySystemFill)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}

// For real-time data handling
extension Notification.Name {
    static let projectUpdated = Notification.Name("projectUpdated")
    static let entriesUpdated = Notification.Name("entriesUpdated")
    static let milestonesUpdated = Notification.Name("milestonesUpdated")
}