//
//  ProfileView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var quizService: QuizService
    @State private var showAchievements = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Stats overview
                    statsOverview
                    
                    // Achievements preview
                    achievementsPreview
                    
                    // Preferences
                    preferencesSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
                .environmentObject(quizService)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryButton, Color.highlightBackground]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text("Q")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text("Quiz Master")
                    .font(.system(.title2, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.textPrimary)
                
                Text("Member since today")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            // Level progress
            levelProgressView
        }
        .padding(.vertical, 20)
        .cardStyle()
    }
    
    private var levelProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(currentLevel)")
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primaryButton)
                
                Spacer()
                
                Text("\(quizService.userProgress.totalScore)/\(nextLevelRequirement) XP")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            ProgressView(value: levelProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryButton))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.horizontal, 16)
    }
    
    private var currentLevel: Int {
        return max(1, quizService.userProgress.totalScore / 100 + 1)
    }
    
    private var nextLevelRequirement: Int {
        return currentLevel * 100
    }
    
    private var levelProgress: Double {
        let currentLevelXP = quizService.userProgress.totalScore % 100
        return Double(currentLevelXP) / 100.0
    }
    
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Stats")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Quizzes Completed",
                    value: "\(quizService.userProgress.completedQuizzes.count)",
                    icon: "checkmark.circle.fill",
                    color: .primaryButton
                )
                
                StatCard(
                    title: "Total Score",
                    value: "\(quizService.userProgress.totalScore)",
                    icon: "star.fill",
                    color: .highlightBackground
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(quizService.userProgress.streak) days",
                    icon: "flame.fill",
                    color: .tertiaryButton
                )
                
                StatCard(
                    title: "Achievements",
                    value: "\(quizService.userProgress.achievements.filter { $0.isUnlocked }.count)",
                    icon: "trophy.fill",
                    color: .secondaryButton
                )
            }
        }
    }
    
    private var achievementsPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(.title2, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    showAchievements = true
                }
                .font(.system(.subheadline, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.medium))
                .foregroundColor(.primaryButton)
            }
            
            if quizService.userProgress.achievements.filter({ $0.isUnlocked }).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.textSecondary)
                    
                    Text("No achievements yet")
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.medium))
                        .foregroundColor(.textSecondary)
                    
                    Text("Complete quizzes to unlock achievements!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .cardStyle()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quizService.userProgress.achievements.filter { $0.isUnlocked }.prefix(3)) { achievement in
                            AchievementCard(achievement: achievement, isCompact: true)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                PreferenceRow(
                    icon: "gamecontroller.fill",
                    title: "Favorite Categories",
                    value: favoriteCategories,
                    color: .primaryButton
                )
                
                PreferenceRow(
                    icon: "speedometer",
                    title: "Preferred Difficulty",
                    value: quizService.userProgress.preferredDifficulty.rawValue,
                    color: .highlightBackground
                )
                
                PreferenceRow(
                    icon: "bell.fill",
                    title: "Daily Reminders",
                    value: "Enabled",
                    color: .tertiaryButton
                )
            }
            .cardStyle()
        }
    }
    
    private var favoriteCategories: String {
        if quizService.userProgress.preferredCategories.isEmpty {
            return "All Categories"
        } else {
            return quizService.userProgress.preferredCategories
                .map { $0.rawValue }
                .joined(separator: ", ")
        }
    }
}

struct PreferenceRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.medium))
                    .foregroundColor(.textPrimary)
                
                Text(value)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 8)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isCompact: Bool
    
    var body: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: isCompact ? 24 : 32))
                .foregroundColor(achievement.isUnlocked ? .highlightBackground : .textSecondary)
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.system(isCompact ? .caption : .subheadline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(isCompact ? 1 : 2)
                
                if !isCompact {
                    Text(achievement.description)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryButton))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
        }
        .frame(width: isCompact ? 100 : 150)
        .frame(height: isCompact ? 100 : 150)
        .padding(isCompact ? 12 : 16)
        .background(
            achievement.isUnlocked 
                ? Color.highlightBackground.opacity(0.1)
                : Color(.systemBackground)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ? Color.highlightBackground.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(QuizService())
}
