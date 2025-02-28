import SwiftUI
import Foundation

// MARK: - Models

enum ProjectStatus: String, CaseIterable, Identifiable, Codable {
    case concept = "Concept"
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .concept: return Color.blue.opacity(0.7)
        case .inProgress: return Color.orange.opacity(0.7)
        case .completed: return Color.green.opacity(0.7)
        }
    }
}

struct Location: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var name: String
    
    static let samples = [
        Location(name: "Workshop"),
        Location(name: "Studio"),
        Location(name: "Home")
    ]
}

struct Project: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var title: String
    var description: String
    var status: ProjectStatus
    var createdAt: Date
    var updatedAt: Date
    var entries: [Entry] = []
    var milestones: [Milestone] = []
    
    static let sample = Project(
        title: "Light Installation",
        description: "Interactive light installation for east gallery",
        status: .inProgress,
        createdAt: Date(),
        updatedAt: Date(),
        entries: Entry.samples,
        milestones: Milestone.samples
    )
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.status == rhs.status &&
        lhs.updatedAt == rhs.updatedAt
    }
}

struct MainProject: Identifiable, Codable {
    var id = UUID().uuidString
    var title: String
    var description: String
    var subProjects: [Project] = []
    
    static let sample = MainProject(
        title: "Graduation Installation 2025",
        description: "Mixed media installation exploring human-technology relationships",
        subProjects: [Project.sample]
    )
}

struct EntryMedia: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var type: MediaType
    var url: String
    var thumbnailUrl: String?
    var createdAt: Date
    
    enum MediaType: String, Codable {
        case image, pdf, sketch, audio, other
    }
    
    static let samples = [
        EntryMedia(
            type: .image,
            url: "placeholder_image_url",
            thumbnailUrl: "placeholder_thumbnail_url",
            createdAt: Date()
        )
    ]
    
    static func == (lhs: EntryMedia, rhs: EntryMedia) -> Bool {
        lhs.id == rhs.id &&
        lhs.url == rhs.url &&
        lhs.type == rhs.type
    }
}

struct Entry: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var title: String
    var content: String
    var media: [EntryMedia] = []
    var location: Location?
    var tags: [String] = []
    var createdAt: Date
    var updatedAt: Date
    
    static let samples = [
        Entry(
            title: "Initial Concept Sketches",
            content: "Drafted the first round of concepts for the light installation using LED strips and motion sensors.",
            media: EntryMedia.samples,
            location: Location.samples[1],
            tags: ["concept", "sketches"],
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: Date().addingTimeInterval(-86400 * 5)
        ),
        Entry(
            title: "Material Research",
            content: "Researched diffusion materials for the LED strips. Need to test acrylic vs. frosted glass.",
            tags: ["materials", "research"],
            createdAt: Date().addingTimeInterval(-86400 * 3),
            updatedAt: Date().addingTimeInterval(-86400 * 3)
        )
    ]
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.updatedAt == rhs.updatedAt
    }
}

struct Milestone: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var title: String
    var description: String
    var dueDate: Date
    var isCompleted: Bool
    
    static let samples = [
        Milestone(
            title: "Finalize Concept",
            description: "Complete all concept sketches and get approval",
            dueDate: Date().addingTimeInterval(86400 * 7),
            isCompleted: false
        ),
        Milestone(
            title: "Order Materials",
            description: "Order all necessary materials for the installation",
            dueDate: Date().addingTimeInterval(86400 * 14),
            isCompleted: false
        )
    ]
    
    static func == (lhs: Milestone, rhs: Milestone) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.dueDate == rhs.dueDate &&
        lhs.isCompleted == rhs.isCompleted
    }
}

struct EntryTemplate: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var contentTemplate: String
    var defaultTags: [String] = []
    
    static let samples = [
        EntryTemplate(
            name: "Daily Progress",
            contentTemplate: "Today I worked on:\n\nChallenges:\n\nNext steps:",
            defaultTags: ["daily"]
        ),
        EntryTemplate(
            name: "Material Test",
            contentTemplate: "Material: \n\nTest setup: \n\nResults: \n\nConclusion:",
            defaultTags: ["material", "test"]
        )
    ]
}
