//
//  QuizModels.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import Foundation

struct Quiz: Identifiable, Codable {
    var id = UUID()
    let title: String
    let category: QuizCategory
    let difficulty: Difficulty
    let questions: [Question]
    let estimatedTime: Int // in minutes
    let description: String
    
    var completionRate: Double {
        // This would be calculated based on user progress
        return 0.0
    }
}

struct Question: Identifiable, Codable {
    var id = UUID()
    let text: String
    let type: QuestionType
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let points: Int
}

enum QuestionType: String, Codable, CaseIterable {
    case multipleChoice = "multiple_choice"
    case trueFalse = "true_false"
    case puzzle = "puzzle"
    case scenario = "scenario"
}

enum QuizCategory: String, Codable, CaseIterable, Identifiable {
    case finance = "Finance"
    case entertainment = "Entertainment"
    case mixed = "Mixed"
    case puzzle = "Puzzle"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .finance:
            return "dollarsign.circle.fill"
        case .entertainment:
            return "gamecontroller.fill"
        case .mixed:
            return "star.fill"
        case .puzzle:
            return "puzzlepiece.fill"
        }
    }
    
    var color: String {
        switch self {
        case .finance:
            return "#1ed55f"
        case .entertainment:
            return "#ffff03"
        case .mixed:
            return "#ffc934"
        case .puzzle:
            return "#eb262f"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy:
            return "#1ed55f"
        case .medium:
            return "#ffc934"
        case .hard:
            return "#eb262f"
        }
    }
}

struct UserProgress: Codable {
    var completedQuizzes: [UUID] = []
    var totalScore: Int = 0
    var achievements: [Achievement] = []
    var streak: Int = 0
    var lastPlayedDate: Date?
    var preferredCategories: [QuizCategory] = []
    var preferredDifficulty: Difficulty = .easy
}

struct Achievement: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let icon: String
    let unlockedDate: Date?
    let isUnlocked: Bool
    let requirement: Int
    let progress: Int
    
    var progressPercentage: Double {
        return min(Double(progress) / Double(requirement), 1.0)
    }
}

struct FinancialTip: Identifiable, Codable {
    var id = UUID()
    let title: String
    let content: String
    let category: String
    let date: Date
    let readingTime: Int // in minutes
}

struct QuizResult {
    let quiz: Quiz
    let score: Int
    let totalPoints: Int
    let timeSpent: TimeInterval
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    var percentage: Double {
        return Double(score) / Double(totalPoints) * 100
    }
    
    var grade: String {
        let percentage = self.percentage
        switch percentage {
        case 90...100:
            return "A+"
        case 80..<90:
            return "A"
        case 70..<80:
            return "B"
        case 60..<70:
            return "C"
        default:
            return "D"
        }
    }
}
