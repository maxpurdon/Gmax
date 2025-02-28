import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var showingAddMilestone = false
    @State private var selectedProjectId: String? = nil
    @State private var showCalendarView = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with filter
            VStack(spacing: 16) {
                Text("Project Timeline")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    if !viewModel.mainProject.subProjects.isEmpty {
                        Menu {
                            Button(action: {
                                selectedProjectId = nil
                            }) {
                                HStack {
                                    Text("All Projects")
                                    if selectedProjectId == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Divider()
                            
                            ForEach(viewModel.mainProject.subProjects) { project in
                                Button(action: {
                                    selectedProjectId = project.id
                                }) {
                                    HStack {
                                        Text(project.title)
                                        if selectedProjectId == project.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(filterLabelText)
                                    .font(.system(size: 16))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showCalendarView.toggle()
                    }) {
                        Image(systemName: showCalendarView ? "list.bullet" : "calendar")
                            .font(.system(size: 16))
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Calendar or list view
            if showCalendarView {
                CalendarTimelineView(milestones: filteredMilestones)
            } else {
                MilestoneListView(
                    upcomingMilestones: upcomingMilestones,
                    completedMilestones: completedMilestones,
                    onToggle: toggleMilestone
                )
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            showingAddMilestone = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 18))
        })
        .sheet(isPresented: $showingAddMilestone) {
            AddMilestoneToProjectView()
                .environmentObject(viewModel)
        }
    }
    
    private var filterLabelText: String {
        if let id = selectedProjectId,
           let project = viewModel.mainProject.subProjects.first(where: { $0.id == id }) {
            return project.title
        } else {
            return "All Projects"
        }
    }
    
    private var allMilestones: [MilestonesView.MilestoneWithProject] {
        var result = [MilestoneWithProject]()
        
        for project in viewModel.mainProject.subProjects {
            if let selectedId = selectedProjectId, project.id != selectedId {
                continue
            }
            
            for milestone in project.milestones {
                result.append(MilestoneWithProject(
                    milestone: milestone,
                    projectId: project.id,
                    projectTitle: project.title
                ))
            }
        }
        
        return result
    }
    
    private var filteredMilestones: [MilestoneWithProject] {
        allMilestones.sorted { $0.milestone.dueDate < $1.milestone.dueDate }
    }
    
    private var upcomingMilestones: [MilestoneWithProject] {
        allMilestones.filter { !$0.milestone.isCompleted }.sorted { $0.milestone.dueDate < $1.milestone.dueDate }
    }
    
    private var completedMilestones: [MilestoneWithProject] {
        allMilestones.filter { $0.milestone.isCompleted }.sorted { $0.milestone.dueDate > $1.milestone.dueDate }
    }
    
    private func toggleMilestone(_ milestoneWithProject: MilestoneWithProject) {
        if let projectIndex = viewModel.mainProject.subProjects.firstIndex(where: { $0.id == milestoneWithProject.projectId }),
           let milestoneIndex = viewModel.mainProject.subProjects[projectIndex].milestones.firstIndex(where: { $0.id == milestoneWithProject.milestone.id }) {
            
            viewModel.mainProject.subProjects[projectIndex].milestones[milestoneIndex].isCompleted.toggle()
            viewModel.saveMainProject()
        }
    }
    
    struct MilestoneWithProject: Identifiable {
        let milestone: Milestone
        let projectId: String
        let projectTitle: String
        
        var id: String { milestone.id }
    }
}

struct CalendarTimelineView: View {
    let milestones: [MilestonesView.MilestoneWithProject]
    
    private let calendar = Calendar.current
    @State private var selectedDate = Date()
    @State private var displayedMonth: Date = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Month selector
            HStack {
                Button(action: {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(formatMonth(displayedMonth))
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Calendar
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Week day headers
                    HStack(spacing: 0) {
                        ForEach(weekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Day cells
                    VStack(spacing: 16) {
                        ForEach(monthDays(for: displayedMonth), id: \.self) { week in
                            HStack(spacing: 0) {
                                ForEach(week, id: \.day) { dayInfo in
                                    DayCell(
                                        dayInfo: dayInfo,
                                        milestones: milestonesForDay(dayInfo.date),
                                        isSelected: calendar.isDate(selectedDate, inSameDayAs: dayInfo.date),
                                        onSelect: { selectedDate = dayInfo.date }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Milestones for selected day
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Milestones")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal)
                        
                        let dayMilestones = milestonesForDay(selectedDate)
                        
                        if dayMilestones.isEmpty {
                            Text("No milestones for this day")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                        } else {
                            ForEach(dayMilestones) { milestone in
                                MilestoneCard(milestone: milestone)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        // Adjust if week starts with Monday
        if calendar.firstWeekday == 2 {
            var adjusted = symbols
            adjusted.append(adjusted.removeFirst())
            return adjusted
        }
        return symbols
    }
    
    private func monthDays(for date: Date) -> [[DayInfo]] {
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        
        let weekdayOffset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [DayInfo] = []
        
        // Add leading empty days
        for _ in 0..<weekdayOffset {
            days.append(DayInfo(day: 0, date: Date(), isInCurrentMonth: false))
        }
        
        // Add days in month
        for day in 1...daysInMonth {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(DayInfo(day: day, date: date, isInCurrentMonth: true))
            }
        }
        
        // Group by weeks (7 days)
        var weeks: [[DayInfo]] = []
        for weekIndex in 0..<6 {
            let weekStart = weekIndex * 7
            if weekStart < days.count {
                let week = Array(days[weekStart..<min(weekStart + 7, days.count)])
                if !week.isEmpty {
                    let filledWeek = fillWeek(week)
                    weeks.append(filledWeek)
                }
            }
        }
        
        return weeks
    }
    
    private func fillWeek(_ week: [DayInfo]) -> [DayInfo] {
        var filledWeek = week
        while filledWeek.count < 7 {
            filledWeek.append(DayInfo(day: 0, date: Date(), isInCurrentMonth: false))
        }
        return filledWeek
    }
    
    private func milestonesForDay(_ date: Date) -> [MilestonesView.MilestoneWithProject] {
        milestones.filter { calendar.isDate($0.milestone.dueDate, inSameDayAs: date) }
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    struct DayInfo: Hashable {
        let day: Int
        let date: Date
        let isInCurrentMonth: Bool
    }
}

struct DayCell: View {
    let dayInfo: CalendarTimelineView.DayInfo
    let milestones: [MilestonesView.MilestoneWithProject]
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            // Day number
            Text(dayInfo.day > 0 ? "\(dayInfo.day)" : "")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(dayTextColor)
                .frame(width: 30, height: 30)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
            
            // Milestone indicator
            if !milestones.isEmpty {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 4)
        .opacity(dayInfo.isInCurrentMonth ? 1 : 0)
        .onTapGesture {
            if dayInfo.isInCurrentMonth {
                onSelect()
            }
        }
    }
    
    private var dayTextColor: Color {
        if isSelected {
            return .white
        } else if Calendar.current.isDateInToday(dayInfo.date) {
            return .blue
        } else {
            return .primary
        }
    }
}

struct MilestoneListView: View {
    let upcomingMilestones: [MilestonesView.MilestoneWithProject]
    let completedMilestones: [MilestonesView.MilestoneWithProject]
    let onToggle: (MilestonesView.MilestoneWithProject) -> Void
    
    var body: some View {
        List {
            if upcomingMilestones.isEmpty && completedMilestones.isEmpty {
                Text("No milestones found")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 20)
            } else {
                if !upcomingMilestones.isEmpty {
                    Section(header: Text("Upcoming").font(.system(size: 16, weight: .semibold))) {
                        ForEach(upcomingMilestones) { milestone in
                            MilestoneRow(milestone: milestone, onToggle: onToggle)
                        }
                    }
                }
                
                if !completedMilestones.isEmpty {
                    Section(header: Text("Completed").font(.system(size: 16, weight: .semibold))) {
                        ForEach(completedMilestones) { milestone in
                            MilestoneRow(milestone: milestone, onToggle: onToggle)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct MilestoneRow: View {
    let milestone: MilestonesView.MilestoneWithProject
    let onToggle: (MilestonesView.MilestoneWithProject) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Completion toggle
            Button(action: {
                onToggle(milestone)
            }) {
                Circle()
                    .stroke(milestone.milestone.isCompleted ? Color.green : Color.gray, lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .background(
                        milestone.milestone.isCompleted ?
                            AnyView(
                                ZStack {
                                    Circle().fill(Color.green)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            ) : AnyView(Circle().fill(Color.clear))
                    )
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                // Milestone info
                Text(milestone.milestone.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(milestone.milestone.isCompleted ? .secondary : .primary)
                    .strikethrough(milestone.milestone.isCompleted)
                
                Text(milestone.milestone.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    // Project
                    Text(milestone.projectTitle)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Due date
                    Label(formatDate(milestone.milestone.dueDate), systemImage: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(dueDateColor(milestone.milestone))
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func dueDateColor(_ milestone: Milestone) -> Color {
        if milestone.isCompleted {
            return .secondary
        }
        
        let days = Calendar.current.dateComponents([.day], from: Date(), to: milestone.dueDate).day ?? 0
        if days < 0 {
            return .red
        } else if days < 3 {
            return .orange
        } else if days < 7 {
            return .yellow
        } else {
            return .secondary
        }
    }
}

struct MilestoneCard: View {
    let milestone: MilestonesView.MilestoneWithProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.milestone.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(milestone.projectTitle)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Circle()
                    .stroke(milestone.milestone.isCompleted ? Color.green : Color.gray, lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .background(
                        milestone.milestone.isCompleted ?
                            AnyView(
                                ZStack {
                                    Circle().fill(Color.green)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            ) : AnyView(Circle().fill(Color.clear))
                    )
            }
            
            Text(milestone.milestone.description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineLimit(4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
