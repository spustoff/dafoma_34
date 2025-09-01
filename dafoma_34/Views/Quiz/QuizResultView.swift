//
//  QuizResultView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct QuizResultView: View {
    let result: QuizResult
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var animateStats = false
    
    private var isExcellentScore: Bool {
        result.percentage >= 80
    }
    
    private var performanceMessage: String {
        switch result.percentage {
        case 90...100:
            return "Outstanding! You're a quiz master!"
        case 80..<90:
            return "Excellent work! Keep it up!"
        case 70..<80:
            return "Good job! You're getting there!"
        case 60..<70:
            return "Not bad! Room for improvement."
        default:
            return "Keep practicing! You'll get better!"
        }
    }
    
    private var gradeColor: Color {
        switch result.grade {
        case "A+", "A":
            return .primaryButton
        case "B":
            return .highlightBackground
        case "C":
            return .secondaryButton
        default:
            return .tertiaryButton
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBackground.opacity(0.1), Color.secondaryBackground.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)
                    
                    // Celebration icon
                    celebrationIcon
                    
                    // Grade and score
                    gradeSection
                    
                    // Performance message
                    Text(performanceMessage)
                        .font(.system(.title3, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.medium))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Stats cards
                    statsSection
                    
                    // Quiz info
                    quizInfoSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom actions
            VStack {
                Spacer()
                bottomActions
            }
            
            // Confetti effect
            if showConfetti && isExcellentScore {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                animateStats = true
            }
            
            if isExcellentScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                }
            }
        }
    }
    
    private var celebrationIcon: some View {
        Image(systemName: isExcellentScore ? "star.fill" : "checkmark.circle.fill")
            .font(.system(size: 80, weight: .light))
            .foregroundColor(isExcellentScore ? .highlightBackground : .primaryButton)
            .scaleEffect(animateStats ? 1.0 : 0.5)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateStats)
    }
    
    private var gradeSection: some View {
        VStack(spacing: 16) {
            // Grade
            Text(result.grade)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(gradeColor)
                .scaleEffect(animateStats ? 1.0 : 0.8)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateStats)
            
            // Score
            Text("\(result.score) / \(result.totalPoints) points")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.textPrimary)
            
            // Percentage
            Text(String(format: "%.0f%%", result.percentage))
                .font(.system(.title, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.primaryButton)
        }
        .padding(.vertical, 20)
        .opacity(animateStats ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.6).delay(0.4), value: animateStats)
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                            ResultStatCard(
                title: "Correct",
                value: "\(result.correctAnswers)",
                subtitle: "out of \(result.totalQuestions)",
                icon: "checkmark.circle.fill",
                color: .primaryButton
            )
            
            ResultStatCard(
                title: "Time",
                value: formatTime(result.timeSpent),
                subtitle: "total time",
                icon: "clock.fill",
                color: .highlightBackground
            )
            }
            
            ResultStatCard(
                title: "Performance",
                value: result.grade,
                subtitle: String(format: "%.0f%% accuracy", result.percentage),
                icon: "chart.line.uptrend.xyaxis",
                color: gradeColor
            )
        }
        .scaleEffect(animateStats ? 1.0 : 0.9)
        .opacity(animateStats ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.6).delay(0.6), value: animateStats)
    }
    
    private var quizInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz Details")
                .font(.system(.title2, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: result.quiz.category.icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: result.quiz.category.color))
                    
                    Text(result.quiz.title)
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                
                HStack {
                    Text(result.quiz.category.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .foregroundColor(.textSecondary)
                    
                    Text(result.quiz.difficulty.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(DateFormatter.shortDate.string(from: result.date))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(16)
            .cardStyle()
        }
        .opacity(animateStats ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.6).delay(0.8), value: animateStats)
    }
    
    private var bottomActions: some View {
        VStack(spacing: 12) {
            // Primary action
            Button(action: onDismiss) {
                Text("Continue")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.primaryButton)
                            .shadow(color: Color.primaryButton.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            
            // Secondary action
            Button(action: {
                // Share result functionality could be added here
                onDismiss()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                    Text("Share Result")
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                }
                .foregroundColor(.primaryButton)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.primaryButton, lineWidth: 2)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct ResultStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.textPrimary)
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .cardStyle()
    }
}

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                ConfettiPiece()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    @State private var animate = false
    private let colors: [Color] = [.primaryButton, .highlightBackground, .tertiaryButton, .secondaryButton]
    private let startX = Double.random(in: -50...UIScreen.main.bounds.width + 50)
    private let endX = Double.random(in: -50...UIScreen.main.bounds.width + 50)
    private let duration = Double.random(in: 2...4)
    private let delay = Double.random(in: 0...2)
    
    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .primaryButton)
            .frame(width: 6, height: 6)
            .position(
                x: animate ? endX : startX,
                y: animate ? UIScreen.main.bounds.height + 50 : -50
            )
            .animation(
                .linear(duration: duration).delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    QuizResultView(
        result: QuizResult(
            quiz: Quiz(
                title: "Sample Quiz",
                category: .finance,
                difficulty: .medium,
                questions: [],
                estimatedTime: 5,
                description: "Sample description"
            ),
            score: 85,
            totalPoints: 100,
            timeSpent: 120,
            correctAnswers: 8,
            totalQuestions: 10,
            date: Date()
        )
    ) {
        // Dismiss action
    }
}
