//
//  LeaderboardView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var quizService: QuizService
    @State private var selectedTimeframe: TimeFrame = .allTime
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case allTime = "All Time"
    }
    
    // Mock leaderboard data since we don't have multiple users
    private var leaderboardData: [LeaderboardEntry] {
        [
            LeaderboardEntry(
                rank: 1,
                name: "You",
                score: quizService.userProgress.totalScore,
                quizzesCompleted: quizService.userProgress.completedQuizzes.count,
                isCurrentUser: true
            ),
            LeaderboardEntry(rank: 2, name: "Alex Chen", score: max(0, quizService.userProgress.totalScore - 50), quizzesCompleted: 12, isCurrentUser: false),
            LeaderboardEntry(rank: 3, name: "Sarah Johnson", score: max(0, quizService.userProgress.totalScore - 80), quizzesCompleted: 10, isCurrentUser: false),
            LeaderboardEntry(rank: 4, name: "Mike Williams", score: max(0, quizService.userProgress.totalScore - 120), quizzesCompleted: 8, isCurrentUser: false),
            LeaderboardEntry(rank: 5, name: "Emma Davis", score: max(0, quizService.userProgress.totalScore - 150), quizzesCompleted: 7, isCurrentUser: false),
            LeaderboardEntry(rank: 6, name: "James Wilson", score: max(0, quizService.userProgress.totalScore - 180), quizzesCompleted: 6, isCurrentUser: false),
            LeaderboardEntry(rank: 7, name: "Lisa Garcia", score: max(0, quizService.userProgress.totalScore - 200), quizzesCompleted: 5, isCurrentUser: false),
            LeaderboardEntry(rank: 8, name: "David Brown", score: max(0, quizService.userProgress.totalScore - 230), quizzesCompleted: 4, isCurrentUser: false)
        ].sorted { $0.score > $1.score }
            .enumerated()
            .map { index, entry in
                LeaderboardEntry(
                    rank: index + 1,
                    name: entry.name,
                    score: entry.score,
                    quizzesCompleted: entry.quizzesCompleted,
                    isCurrentUser: entry.isCurrentUser
                )
            }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with user stats
                headerView
                
                // Time frame selector
                timeFrameSelector
                
                // Leaderboard list
                leaderboardList
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Your rank card
            if let userEntry = leaderboardData.first(where: { $0.isCurrentUser }) {
                YourRankCard(entry: userEntry)
            }
            
            // Top performers
            topPerformersView
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var topPerformersView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Performers")
                .font(.system(.headline, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(Array(leaderboardData.prefix(3).enumerated()), id: \.element.id) { index, entry in
                    TopPerformerCard(entry: entry, position: index)
                }
            }
        }
    }
    
    private var timeFrameSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Button(action: {
                        selectedTimeframe = timeframe
                    }) {
                        Text(timeframe.rawValue)
                            .font(.system(.subheadline, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.medium))
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTimeframe == timeframe ? Color.primaryButton : Color(.systemBackground))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var leaderboardList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(leaderboardData) { entry in
                    LeaderboardRow(entry: entry)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let score: Int
    let quizzesCompleted: Int
    let isCurrentUser: Bool
}

struct YourRankCard: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Rank")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("#\(entry.rank)")
                    .font(.system(.title, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.primaryButton)
            }
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(entry.score)")
                        .font(.system(.title2, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(.textPrimary)
                    Text("Points")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack {
                    Text("\(entry.quizzesCompleted)")
                        .font(.system(.title2, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(.textPrimary)
                    Text("Quizzes")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.highlightBackground)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryButton.opacity(0.1), Color.highlightBackground.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryButton.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TopPerformerCard: View {
    let entry: LeaderboardEntry
    let position: Int
    
    private var medalIcon: String {
        switch position {
        case 0: return "medal.fill"
        case 1: return "medal.fill"
        case 2: return "medal.fill"
        default: return "person.circle.fill"
        }
    }
    
    private var medalColor: Color {
        switch position {
        case 0: return Color(hex: "#FFD700") // Gold
        case 1: return Color(hex: "#C0C0C0") // Silver
        case 2: return Color(hex: "#CD7F32") // Bronze
        default: return .textSecondary
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: medalIcon)
                .font(.title)
                .foregroundColor(medalColor)
            
            Text(entry.name)
                .font(.system(.caption, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            
            Text("\(entry.score)")
                .font(.system(.caption2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(entry.isCurrentUser ? Color.primaryButton : Color.clear, lineWidth: 2)
        )
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    private var rankIcon: String {
        switch entry.rank {
        case 1: return "crown.fill"
        case 2, 3: return "medal.fill"
        default: return ""
        }
    }
    
    private var rankColor: Color {
        switch entry.rank {
        case 1: return Color(hex: "#FFD700")
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return .textSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            HStack {
                if !rankIcon.isEmpty {
                    Image(systemName: rankIcon)
                        .font(.title3)
                        .foregroundColor(rankColor)
                }
                
                Text("#\(entry.rank)")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(entry.isCurrentUser ? .primaryButton : .textPrimary)
                    .frame(minWidth: 30, alignment: .leading)
            }
            
            // Avatar
            Circle()
                .fill(entry.isCurrentUser ? Color.primaryButton : Color.textSecondary)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(entry.name.prefix(1)))
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                )
            
            // Name and stats
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
                
                Text("\(entry.quizzesCompleted) quizzes completed")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Score
            Text("\(entry.score)")
                .font(.system(.title3, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(entry.isCurrentUser ? .primaryButton : .textPrimary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(entry.isCurrentUser ? Color.primaryButton : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(QuizService())
}

