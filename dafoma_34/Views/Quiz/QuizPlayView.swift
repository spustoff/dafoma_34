//
//  QuizPlayView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct QuizPlayView: View {
    let quiz: Quiz
    @EnvironmentObject var quizService: QuizService
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitAlert = false
    
    init(quiz: Quiz) {
        self.quiz = quiz
        self._viewModel = StateObject(wrappedValue: QuizViewModel(quizService: QuizService()))
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
            
            if viewModel.quizCompleted {
                QuizResultView(result: viewModel.getQuizResult()!) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Question content
                    questionView
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Answer options
                    if let question = viewModel.currentQuestion {
                        answerOptionsView(question: question)
                            .padding(.horizontal, 20)
                    }
                    
                    // Bottom actions
                    bottomActionsView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            viewModel.startQuiz(quiz)
        }
        .alert("Exit Quiz?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                viewModel.resetQuiz()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your progress will be lost if you exit now.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack {
                Button(action: {
                    showExitAlert = true
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                // Timer
                if viewModel.timeRemaining > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(formatTime(viewModel.timeRemaining))
                            .font(.system(.caption, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.medium))
                    }
                    .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Score
                Text("\(viewModel.score) pts")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.primaryButton)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.system(.subheadline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.medium))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryButton))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let question = viewModel.currentQuestion {
                VStack(alignment: .leading, spacing: 16) {
                    // Question type and points
                    HStack {
                        Text(question.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(.caption, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundColor(.primaryButton)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryButton.opacity(0.1))
                            )
                        
                        Spacer()
                        
                        Text("\(question.points) points")
                            .font(.system(.caption, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundColor(.highlightBackground)
                    }
                    
                    // Question text
                    Text(question.text)
                        .font(.system(.title2, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .cardStyle()
                
                // Explanation (if shown)
                if viewModel.showExplanation {
                    explanationView(question: question)
                }
            }
        }
    }
    
    private func answerOptionsView(question: Question) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                AnswerOptionButton(
                    text: option,
                    isSelected: viewModel.selectedAnswer == index,
                    isCorrect: viewModel.showExplanation ? index == question.correctAnswer : nil,
                    isWrong: viewModel.showExplanation && viewModel.selectedAnswer == index && index != question.correctAnswer
                ) {
                    if !viewModel.showExplanation {
                        viewModel.selectAnswer(index)
                    }
                }
            }
        }
    }
    
    private func explanationView(question: Question) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(.highlightBackground)
                
                Text("Explanation")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textPrimary)
            }
            
            Text(question.explanation)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.highlightBackground.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var bottomActionsView: some View {
        VStack(spacing: 16) {
            if !viewModel.showExplanation {
                // Submit button
                Button(action: {
                    viewModel.submitAnswer()
                }) {
                    Text("Submit Answer")
                        .font(.system(.headline, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(viewModel.selectedAnswer != nil ? Color.primaryButton : Color.textSecondary)
                        )
                }
                .disabled(viewModel.selectedAnswer == nil)
            } else {
                // Next button
                Button(action: {
                    viewModel.nextQuestion()
                }) {
                    HStack {
                        Text(viewModel.isLastQuestion ? "Finish Quiz" : "Next Question")
                            .font(.system(.headline, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                        
                        if !viewModel.isLastQuestion {
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.primaryButton)
                    )
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AnswerOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .primaryButton : (isWrong ? .tertiaryButton : .cardBackground)
        } else {
            return isSelected ? .primaryButton.opacity(0.1) : .cardBackground
        }
    }
    
    private var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .primaryButton : (isWrong ? .tertiaryButton : .clear)
        } else {
            return isSelected ? .primaryButton : .clear
        }
    }
    
    private var textColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect || isWrong ? .white : .textPrimary
        } else {
            return .textPrimary
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(.body, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isWrong ? "xmark.circle.fill" : ""))
                        .font(.title3)
                        .foregroundColor(.white)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.primaryButton)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuizPlayView(quiz: Quiz(
        title: "Sample Quiz",
        category: .finance,
        difficulty: .medium,
        questions: [
            Question(
                text: "What is compound interest?",
                type: .multipleChoice,
                options: [
                    "Interest earned only on the principal amount",
                    "Interest earned on both principal and previously earned interest",
                    "A type of loan with fixed payments",
                    "Interest that decreases over time"
                ],
                correctAnswer: 1,
                explanation: "Compound interest is interest calculated on the initial principal and also on the accumulated interest from previous periods.",
                points: 10
            )
        ],
        estimatedTime: 5,
        description: "A sample quiz for preview"
    ))
    .environmentObject(QuizService())
}
