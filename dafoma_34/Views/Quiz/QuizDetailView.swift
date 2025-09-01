//
//  QuizDetailView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct QuizDetailView: View {
    let quiz: Quiz
    @EnvironmentObject var quizService: QuizService
    @State private var showQuizPlay = false
    
    var isCompleted: Bool {
        quizService.userProgress.completedQuizzes.contains(quiz.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header card
                headerCard
                
                // Quiz info
                infoSection
                
                // Questions preview
                questionsPreview
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(quiz.title)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            startButton
        }
        .fullScreenCover(isPresented: $showQuizPlay) {
            QuizPlayView(quiz: quiz)
                .environmentObject(quizService)
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Category
                HStack(spacing: 8) {
                    Image(systemName: quiz.category.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: quiz.category.color))
                    
                    Text(quiz.category.rawValue)
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                // Completion status
                if isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primaryButton)
                        Text("Completed")
                            .font(.system(.caption, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.medium))
                            .foregroundColor(.primaryButton)
                    }
                }
            }
            
            // Description
            Text(quiz.description)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .cardStyle()
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz Information")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "questionmark.circle.fill",
                    title: "Questions",
                    value: "\(quiz.questions.count)",
                    color: .primaryButton
                )
                
                InfoRow(
                    icon: "clock.fill",
                    title: "Estimated Time",
                    value: "\(quiz.estimatedTime) minutes",
                    color: .highlightBackground
                )
                
                InfoRow(
                    icon: "star.fill",
                    title: "Total Points",
                    value: "\(quiz.questions.reduce(0) { $0 + $1.points })",
                    color: .tertiaryButton
                )
                
                InfoRow(
                    icon: "speedometer",
                    title: "Difficulty",
                    value: quiz.difficulty.rawValue,
                    color: Color(hex: quiz.difficulty.color)
                )
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    private var questionsPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Questions Preview")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(Array(quiz.questions.enumerated()), id: \.offset) { index, question in
                    QuestionPreviewCard(
                        number: index + 1,
                        question: question
                    )
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            showQuizPlay = true
        }) {
            HStack {
                Image(systemName: isCompleted ? "arrow.clockwise" : "play.fill")
                    .font(.headline)
                
                Text(isCompleted ? "Retake Quiz" : "Start Quiz")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.primaryButton)
                    .shadow(color: Color.primaryButton.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
}

struct InfoRow: View {
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
            
            Text(title)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(.body, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.textPrimary)
        }
    }
}

struct QuestionPreviewCard: View {
    let number: Int
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Question \(number)")
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primaryButton)
                
                Spacer()
                
                Text("\(question.points) pts")
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.medium))
                    .foregroundColor(.textSecondary)
            }
            
            Text(question.text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            HStack {
                Text(question.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(.caption2, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.medium))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text("\(question.options.count) options")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        QuizDetailView(quiz: Quiz(
            title: "Sample Quiz",
            category: .finance,
            difficulty: .medium,
            questions: [
                Question(
                    text: "What is compound interest?",
                    type: .multipleChoice,
                    options: ["Option A", "Option B", "Option C", "Option D"],
                    correctAnswer: 1,
                    explanation: "Sample explanation",
                    points: 10
                )
            ],
            estimatedTime: 5,
            description: "A sample quiz for preview"
        ))
        .environmentObject(QuizService())
    }
}
