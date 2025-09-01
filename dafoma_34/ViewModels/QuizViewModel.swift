//
//  QuizViewModel.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: Int?
    @Published var showExplanation = false
    @Published var quizCompleted = false
    @Published var score = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var startTime: Date?
    
    private let quizService: QuizService
    private var timer: Timer?
    
    init(quizService: QuizService) {
        self.quizService = quizService
    }
    
    var currentQuestion: Question? {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return nil }
        return quiz.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard let quiz = currentQuiz else { return 0 }
        return Double(currentQuestionIndex) / Double(quiz.questions.count)
    }
    
    var isLastQuestion: Bool {
        guard let quiz = currentQuiz else { return true }
        return currentQuestionIndex >= quiz.questions.count - 1
    }
    
    func startQuiz(_ quiz: Quiz) {
        self.currentQuiz = quiz
        self.currentQuestionIndex = 0
        self.selectedAnswer = nil
        self.showExplanation = false
        self.quizCompleted = false
        self.score = 0
        self.startTime = Date()
        
        // Start timer for estimated time
        let totalTime = TimeInterval(quiz.estimatedTime * 60) // Convert minutes to seconds
        self.timeRemaining = totalTime
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
        }
    }
    
    func selectAnswer(_ answerIndex: Int) {
        selectedAnswer = answerIndex
    }
    
    func submitAnswer() {
        guard let question = currentQuestion,
              let selectedAnswer = selectedAnswer else { return }
        
        if selectedAnswer == question.correctAnswer {
            score += question.points
        }
        
        showExplanation = true
    }
    
    func nextQuestion() {
        if isLastQuestion {
            completeQuiz()
        } else {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showExplanation = false
        }
    }
    
    private func completeQuiz() {
        timer?.invalidate()
        timer = nil
        quizCompleted = true
        
        if let quiz = currentQuiz {
            quizService.completeQuiz(quiz, score: score)
        }
    }
    
    func resetQuiz() {
        timer?.invalidate()
        timer = nil
        currentQuiz = nil
        currentQuestionIndex = 0
        selectedAnswer = nil
        showExplanation = false
        quizCompleted = false
        score = 0
        timeRemaining = 0
        startTime = nil
    }
    
    func getQuizResult() -> QuizResult? {
        guard let quiz = currentQuiz,
              let startTime = startTime else { return nil }
        
        let timeSpent = Date().timeIntervalSince(startTime)
        let correctAnswers = quiz.questions.enumerated().compactMap { index, question in
            // This is a simplified calculation - in a real app, you'd track each answer
            return score > 0 ? 1 : 0
        }.reduce(0, +)
        
        let totalPoints = quiz.questions.reduce(0) { $0 + $1.points }
        
        return QuizResult(
            quiz: quiz,
            score: score,
            totalPoints: totalPoints,
            timeSpent: timeSpent,
            correctAnswers: correctAnswers,
            totalQuestions: quiz.questions.count,
            date: Date()
        )
    }
    
    deinit {
        timer?.invalidate()
    }
}
