//
//  QuizListView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct QuizListView: View {
    @EnvironmentObject var quizService: QuizService
    @State private var selectedCategory: QuizCategory?
    @State private var selectedDifficulty: Difficulty?
    @State private var searchText = ""
    
    var filteredQuizzes: [Quiz] {
        var quizzes = quizService.quizzes
        
        if let category = selectedCategory {
            quizzes = quizzes.filter { $0.category == category }
        }
        
        if let difficulty = selectedDifficulty {
            quizzes = quizzes.filter { $0.difficulty == difficulty }
        }
        
        if !searchText.isEmpty {
            quizzes = quizzes.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return quizzes
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Filters
                filterBar
                
                // Quiz list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredQuizzes) { quiz in
                            NavigationLink(destination: QuizDetailView(quiz: quiz)) {
                                QuizCard(quiz: quiz)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Quizzes")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField("Search quizzes...", text: $searchText)
                .font(.system(.body, design: .rounded))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Category filters
                FilterChip(
                    title: "All Categories",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
                
                Divider()
                    .frame(height: 20)
                
                // Difficulty filters
                FilterChip(
                    title: "All Levels",
                    isSelected: selectedDifficulty == nil,
                    action: { selectedDifficulty = nil }
                )
                
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    FilterChip(
                        title: difficulty.rawValue,
                        isSelected: selectedDifficulty == difficulty,
                        action: { selectedDifficulty = difficulty }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.medium))
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.primaryButton : Color(.systemBackground))
                )
        }
    }
}

struct QuizCard: View {
    let quiz: Quiz
    @EnvironmentObject var quizService: QuizService
    
    var isCompleted: Bool {
        quizService.userProgress.completedQuizzes.contains(quiz.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category icon and name
                HStack(spacing: 8) {
                    Image(systemName: quiz.category.icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: quiz.category.color))
                    
                    Text(quiz.category.rawValue)
                        .font(.system(.caption, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Difficulty badge
                Text(quiz.difficulty.rawValue)
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: quiz.difficulty.color))
                    )
                
                // Completion indicator
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.primaryButton)
                }
            }
            
            // Title
            Text(quiz.title)
                .font(.system(.headline, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
            
            // Description
            Text(quiz.description)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Stats
            HStack(spacing: 16) {
                Label("\(quiz.questions.count) questions", systemImage: "questionmark.circle")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                
                Label("\(quiz.estimatedTime) min", systemImage: "clock")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                // Points
                Text("\(quiz.questions.reduce(0) { $0 + $1.points }) pts")
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primaryButton)
            }
        }
        .padding(16)
        .cardStyle()
    }
}

struct CategoryQuizListView: View {
    let category: QuizCategory
    @EnvironmentObject var quizService: QuizService
    @Environment(\.presentationMode) var presentationMode
    
    var categoryQuizzes: [Quiz] {
        quizService.quizzes.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(categoryQuizzes) { quiz in
                        NavigationLink(destination: QuizDetailView(quiz: quiz)) {
                            QuizCard(quiz: quiz)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    QuizListView()
        .environmentObject(QuizService())
}
