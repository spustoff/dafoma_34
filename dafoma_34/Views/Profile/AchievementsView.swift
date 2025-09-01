//
//  AchievementsView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var quizService: QuizService
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFilter: AchievementFilter = .all
    
    enum AchievementFilter: String, CaseIterable {
        case all = "All"
        case unlocked = "Unlocked"
        case locked = "Locked"
    }
    
    private var filteredAchievements: [Achievement] {
        switch selectedFilter {
        case .all:
            return quizService.userProgress.achievements
        case .unlocked:
            return quizService.userProgress.achievements.filter { $0.isUnlocked }
        case .locked:
            return quizService.userProgress.achievements.filter { !$0.isUnlocked }
        }
    }
    
    private var unlockedCount: Int {
        quizService.userProgress.achievements.filter { $0.isUnlocked }.count
    }
    
    private var totalCount: Int {
        quizService.userProgress.achievements.count
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with progress
                headerView
                
                // Filter tabs
                filterTabs
                
                // Achievements grid
                achievementsGrid
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.textSecondary.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(unlockedCount) / CGFloat(totalCount))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.primaryButton, Color.highlightBackground]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: unlockedCount)
                
                VStack(spacing: 2) {
                    Text("\(unlockedCount)")
                        .font(.system(.title2, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(.textPrimary)
                    
                    Text("of \(totalCount)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
            }
            
            VStack(spacing: 4) {
                Text("Achievement Progress")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
                
                Text("\(Int((Double(unlockedCount) / Double(totalCount)) * 100))% Complete")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
    }
    
    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(AchievementFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(filter.rawValue)
                            .font(.system(.subheadline, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.medium))
                            .foregroundColor(selectedFilter == filter ? .primaryButton : .textSecondary)
                        
                        Rectangle()
                            .fill(selectedFilter == filter ? Color.primaryButton : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
    }
    
    private var achievementsGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(filteredAchievements) { achievement in
                    DetailedAchievementCard(achievement: achievement)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
}

struct DetailedAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: achievement.icon)
                .font(.system(size: 32))
                .foregroundColor(achievement.isUnlocked ? .highlightBackground : .textSecondary)
            
            // Title and description
            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Progress or completion status
            if achievement.isUnlocked {
                completionStatus
            } else {
                progressView
            }
        }
        .frame(height: 180)
        .padding(16)
        .background(
            achievement.isUnlocked 
                ? Color.highlightBackground.opacity(0.1)
                : Color(.systemBackground)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ? Color.highlightBackground.opacity(0.3) : Color.textSecondary.opacity(0.1),
                    lineWidth: 1
                )
        )
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
    
    private var completionStatus: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.primaryButton)
            
            Text("Unlocked")
                .font(.system(.caption, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.primaryButton)
            
            if let unlockedDate = achievement.unlockedDate {
                Text(DateFormatter.shortDate.string(from: unlockedDate))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 6) {
            Text("\(achievement.progress)/\(achievement.requirement)")
                .font(.system(.caption, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.textPrimary)
            
            ProgressView(value: achievement.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryButton))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            
            Text("\(Int(achievement.progressPercentage * 100))% complete")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(QuizService())
}
