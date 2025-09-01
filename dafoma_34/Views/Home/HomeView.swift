//
//  HomeView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var quizService: QuizService
    @State private var selectedCategory: QuizCategory? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Today's tip card
                    if let todaysTip = quizService.getTodaysTip() {
                        todaysTipCard(todaysTip)
                    }
                    
                    // Quick stats
                    statsView
                    
                    // Categories
                    categoriesView
                    
                    // Recent achievements
                    if !quizService.userProgress.achievements.filter({ $0.isUnlocked }).isEmpty {
                        recentAchievementsView
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryBackground.opacity(0.1), Color.secondaryBackground.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("QuizzOne")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome back!")
                        .font(.system(.title2, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text("Ready for your next challenge?")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Streak indicator
                VStack {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.tertiaryButton)
                    Text("\(quizService.userProgress.streak)")
                        .font(.system(.caption, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private func todaysTipCard(_ tip: FinancialTip) -> some View {
        NavigationLink(destination: FinancialTipDetailView(tip: tip)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.highlightBackground)
                    
                    Text("Today's Financial Tip")
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text("\(tip.readingTime) min")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                
                Text(tip.title)
                    .font(.system(.subheadline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.medium))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text(tip.content)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statsView: some View {
        HStack(spacing: 15) {
            StatCard(
                title: "Quizzes",
                value: "\(quizService.userProgress.completedQuizzes.count)",
                icon: "checkmark.circle.fill",
                color: .primaryButton
            )
            
            StatCard(
                title: "Score",
                value: "\(quizService.userProgress.totalScore)",
                icon: "star.fill",
                color: .highlightBackground
            )
            
            StatCard(
                title: "Streak",
                value: "\(quizService.userProgress.streak)",
                icon: "flame.fill",
                color: .tertiaryButton
            )
        }
    }
    
    private var categoriesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categories")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    CategoryCard(category: category) {
                        selectedCategory = category
                    }
                }
            }
        }
        .sheet(item: $selectedCategory) { category in
            CategoryQuizListView(category: category)
                .environmentObject(quizService)
        }
    }
    
    private var recentAchievementsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Achievements")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.title3, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .cardStyle()
    }
}

struct CategoryCard: View {
    let category: QuizCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: category.color))
                
                Text(category.rawValue)
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(QuizService())
}
