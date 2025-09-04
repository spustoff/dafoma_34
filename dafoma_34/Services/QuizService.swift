//
//  QuizService.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import Foundation

class QuizService: ObservableObject {
    @Published var quizzes: [Quiz] = []
    @Published var financialTips: [FinancialTip] = []
    @Published var userProgress: UserProgress = UserProgress()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "UserProgress"
    
    init() {
        loadUserProgress()
        loadQuizzes()
        loadFinancialTips()
    }
    
    // MARK: - Quiz Management
    
    func loadQuizzes() {
        quizzes = createSampleQuizzes()
    }
    
    func getQuizzesByCategory(_ category: QuizCategory) -> [Quiz] {
        return quizzes.filter { $0.category == category }
    }
    
    func getQuizzesByDifficulty(_ difficulty: Difficulty) -> [Quiz] {
        return quizzes.filter { $0.difficulty == difficulty }
    }
    
    // MARK: - User Progress
    
    func loadUserProgress() {
        if let data = userDefaults.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        } else {
            userProgress = UserProgress()
            userProgress.achievements = createAchievements()
        }
    }
    
    func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            userDefaults.set(data, forKey: progressKey)
        }
    }
    
    func completeQuiz(_ quiz: Quiz, score: Int) {
        userProgress.completedQuizzes.append(quiz.id)
        userProgress.totalScore += score
        
        // Update streak
        let today = Calendar.current.startOfDay(for: Date())
        if let lastPlayed = userProgress.lastPlayedDate {
            let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                userProgress.streak += 1
            } else if daysBetween > 1 {
                userProgress.streak = 1
            }
        } else {
            userProgress.streak = 1
        }
        
        userProgress.lastPlayedDate = Date()
        
        // Check for achievements
        updateAchievements()
        saveUserProgress()
    }
    
    // MARK: - Achievements
    
    private func createAchievements() -> [Achievement] {
        return [
            Achievement(
                title: "First Steps",
                description: "Complete your first quiz",
                icon: "star.fill",
                unlockedDate: nil,
                isUnlocked: false,
                requirement: 1,
                progress: 0
            ),
            Achievement(
                title: "Quiz Master",
                description: "Complete 10 quizzes",
                icon: "crown.fill",
                unlockedDate: nil,
                isUnlocked: false,
                requirement: 10,
                progress: 0
            ),
            Achievement(
                title: "Financial Guru",
                description: "Complete 5 finance quizzes",
                icon: "dollarsign.circle.fill",
                unlockedDate: nil,
                isUnlocked: false,
                requirement: 5,
                progress: 0
            ),
            Achievement(
                title: "Streak Champion",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                unlockedDate: nil,
                isUnlocked: false,
                requirement: 7,
                progress: 0
            ),
            Achievement(
                title: "High Scorer",
                description: "Reach 1000 total points",
                icon: "trophy.fill",
                unlockedDate: nil,
                isUnlocked: false,
                requirement: 1000,
                progress: 0
            )
        ]
    }
    
    private func updateAchievements() {
        for i in 0..<userProgress.achievements.count {
            let achievement = userProgress.achievements[i]
            
            switch achievement.title {
            case "First Steps":
                userProgress.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlockedDate: userProgress.completedQuizzes.count >= 1 ? Date() : nil,
                    isUnlocked: userProgress.completedQuizzes.count >= 1,
                    requirement: achievement.requirement,
                    progress: userProgress.completedQuizzes.count
                )
            case "Quiz Master":
                userProgress.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlockedDate: userProgress.completedQuizzes.count >= 10 ? Date() : nil,
                    isUnlocked: userProgress.completedQuizzes.count >= 10,
                    requirement: achievement.requirement,
                    progress: userProgress.completedQuizzes.count
                )
            case "Financial Guru":
                let financeQuizzes = userProgress.completedQuizzes.filter { id in
                    quizzes.first { $0.id == id }?.category == .finance
                }.count
                userProgress.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlockedDate: financeQuizzes >= 5 ? Date() : nil,
                    isUnlocked: financeQuizzes >= 5,
                    requirement: achievement.requirement,
                    progress: financeQuizzes
                )
            case "Streak Champion":
                userProgress.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlockedDate: userProgress.streak >= 7 ? Date() : nil,
                    isUnlocked: userProgress.streak >= 7,
                    requirement: achievement.requirement,
                    progress: userProgress.streak
                )
            case "High Scorer":
                userProgress.achievements[i] = Achievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlockedDate: userProgress.totalScore >= 1000 ? Date() : nil,
                    isUnlocked: userProgress.totalScore >= 1000,
                    requirement: achievement.requirement,
                    progress: userProgress.totalScore
                )
            default:
                break
            }
        }
    }
    
    // MARK: - Financial Tips
    
    func loadFinancialTips() {
        financialTips = createSampleFinancialTips()
    }
    
    func getTodaysTip() -> FinancialTip? {
        let today = Calendar.current.startOfDay(for: Date())
        return financialTips.first { tip in
            Calendar.current.isDate(tip.date, inSameDayAs: today)
        }
    }
    
    // MARK: - Sample Data
    
    private func createSampleQuizzes() -> [Quiz] {
        return [
            // Finance Quizzes
            Quiz(
                title: "Basic Financial Literacy",
                category: .finance,
                difficulty: .easy,
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
                    ),
                    Question(
                        text: "An emergency fund should typically cover how many months of expenses?",
                        type: .multipleChoice,
                        options: [
                            "1-2 months",
                            "3-6 months",
                            "12-24 months",
                            "No emergency fund is needed"
                        ],
                        correctAnswer: 1,
                        explanation: "Financial experts recommend having 3-6 months of living expenses saved in an emergency fund.",
                        points: 10
                    ),
                    Question(
                        text: "Diversification helps reduce investment risk.",
                        type: .trueFalse,
                        options: ["True", "False"],
                        correctAnswer: 0,
                        explanation: "Diversification spreads risk across different investments, reducing the impact of any single investment's poor performance.",
                        points: 10
                    )
                ],
                estimatedTime: 5,
                description: "Test your knowledge of fundamental financial concepts"
            ),
            
            Quiz(
                title: "Investment Strategies",
                category: .finance,
                difficulty: .medium,
                questions: [
                    Question(
                        text: "What is dollar-cost averaging?",
                        type: .multipleChoice,
                        options: [
                            "Investing a lump sum all at once",
                            "Investing fixed amounts regularly regardless of price",
                            "Only buying stocks when prices are low",
                            "Averaging the cost of different investments"
                        ],
                        correctAnswer: 1,
                        explanation: "Dollar-cost averaging involves investing a fixed amount regularly, which can help reduce the impact of market volatility.",
                        points: 15
                    ),
                    Question(
                        text: "A bull market is characterized by rising prices.",
                        type: .trueFalse,
                        options: ["True", "False"],
                        correctAnswer: 0,
                        explanation: "A bull market is a period of generally rising prices and investor optimism.",
                        points: 15
                    )
                ],
                estimatedTime: 7,
                description: "Explore different investment approaches and market concepts"
            ),
            
            // Entertainment Quizzes
            Quiz(
                title: "Movie Trivia Challenge",
                category: .entertainment,
                difficulty: .easy,
                questions: [
                    Question(
                        text: "Which movie won the Academy Award for Best Picture in 2020?",
                        type: .multipleChoice,
                        options: [
                            "1917",
                            "Joker",
                            "Parasite",
                            "Once Upon a Time in Hollywood"
                        ],
                        correctAnswer: 2,
                        explanation: "Parasite made history as the first non-English language film to win Best Picture.",
                        points: 10
                    ),
                    Question(
                        text: "The movie 'Titanic' was released in 1997.",
                        type: .trueFalse,
                        options: ["True", "False"],
                        correctAnswer: 0,
                        explanation: "Titanic was indeed released in 1997 and became one of the highest-grossing films of all time.",
                        points: 10
                    )
                ],
                estimatedTime: 4,
                description: "Test your knowledge of movies and cinema"
            ),
            
            // Mixed Quiz
            Quiz(
                title: "Money & Entertainment Mix",
                category: .mixed,
                difficulty: .medium,
                questions: [
                    Question(
                        text: "Which TV show features characters working on Wall Street?",
                        type: .multipleChoice,
                        options: [
                            "Breaking Bad",
                            "Suits",
                            "Billions",
                            "The Office"
                        ],
                        correctAnswer: 2,
                        explanation: "Billions is a drama series that focuses on the world of high finance and hedge funds.",
                        points: 15
                    ),
                    Question(
                        text: "What does ROI stand for in business?",
                        type: .multipleChoice,
                        options: [
                            "Rate of Interest",
                            "Return on Investment",
                            "Risk of Investment",
                            "Revenue over Income"
                        ],
                        correctAnswer: 1,
                        explanation: "ROI stands for Return on Investment, a measure of investment efficiency.",
                        points: 15
                    )
                ],
                estimatedTime: 6,
                description: "A blend of entertainment and financial knowledge"
            ),
            
            // Puzzle Quiz
            Quiz(
                title: "Financial Puzzles",
                category: .puzzle,
                difficulty: .hard,
                questions: [
                    Question(
                        text: "If you invest $1000 at 5% annual compound interest, how much will you have after 2 years?",
                        type: .multipleChoice,
                        options: [
                            "$1100",
                            "$1102.50",
                            "$1050",
                            "$1200"
                        ],
                        correctAnswer: 1,
                        explanation: "Using the compound interest formula: $1000 × (1.05)² = $1102.50",
                        points: 20
                    ),
                    Question(
                        text: "You have $100. You spend 25% on groceries, then 20% of what's left on gas. How much do you have remaining?",
                        type: .multipleChoice,
                        options: [
                            "$55",
                            "$60",
                            "$65",
                            "$70"
                        ],
                        correctAnswer: 1,
                        explanation: "After groceries: $75. After gas (20% of $75 = $15): $75 - $15 = $60",
                        points: 20
                    )
                ],
                estimatedTime: 10,
                description: "Challenge yourself with financial calculations and logic puzzles"
            )
        ]
    }
    
    private func createSampleFinancialTips() -> [FinancialTip] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            FinancialTip(
                title: "Start Small with Investing",
                content: "You don't need thousands of dollars to start investing. Many brokerages now offer fractional shares, allowing you to invest with as little as $1. The key is to start early and be consistent.",
                category: "Investing",
                date: today,
                readingTime: 2
            ),
            FinancialTip(
                title: "The 50/30/20 Rule",
                content: "A simple budgeting method: allocate 50% of your income to needs, 30% to wants, and 20% to savings and debt repayment. This provides a balanced approach to managing your money.",
                category: "Budgeting",
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                readingTime: 3
            ),
            FinancialTip(
                title: "Automate Your Savings",
                content: "Set up automatic transfers to your savings account right after payday. When you automate your savings, you're paying yourself first and building wealth without having to think about it.",
                category: "Saving",
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                readingTime: 2
            ),
            FinancialTip(
                title: "Understand Your Credit Score",
                content: "Your credit score affects loan rates, insurance premiums, and even job opportunities. Check your credit report regularly and pay bills on time to maintain a good score.",
                category: "Credit",
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                readingTime: 4
            ),
            FinancialTip(
                title: "Diversify Your Income",
                content: "Don't rely solely on your job for income. Consider developing multiple income streams through side hustles, investments, or passive income sources to increase financial security.",
                category: "Income",
                date: calendar.date(byAdding: .day, value: -4, to: today) ?? today,
                readingTime: 3
            )
        ]
    }
}

