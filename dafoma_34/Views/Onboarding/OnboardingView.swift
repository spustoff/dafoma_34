//
//  OnboardingView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var selectedCategories: Set<QuizCategory> = []
    @State private var selectedDifficulty: Difficulty = .easy
    
    let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBackground, Color.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(
                        page: pages[index],
                        selectedCategories: $selectedCategories,
                        selectedDifficulty: $selectedDifficulty,
                        onComplete: {
                            if index == pages.count - 1 {
                                completeOnboarding()
                            } else {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage = index + 1
                                }
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom page indicator
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.highlightBackground : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(selectedCategories.map { $0.rawValue }, forKey: "PreferredCategories")
        UserDefaults.standard.set(selectedDifficulty.rawValue, forKey: "PreferredDifficulty")
        
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var selectedCategories: Set<QuizCategory>
    @Binding var selectedDifficulty: Difficulty
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height > 800 ? 40 : 20) {
                    // Top spacer - adaptive
                    Spacer()
                        .frame(minHeight: 20, maxHeight: geometry.size.height * 0.1)
                    
                    // Icon
                    Image(systemName: page.icon)
                        .font(.system(size: geometry.size.width > 600 ? 100 : 80, weight: .light))
                        .foregroundColor(.highlightBackground)
                        .padding(.top, geometry.size.height > 800 ? 50 : 20)
                    
                    // Title
                    Text(page.title)
                        .font(.system(geometry.size.width > 600 ? .title : .largeTitle, design: .rounded).weight(.bold))
                        .foregroundColor(.textOnDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Description
                    Text(page.description)
                        .font(.system(geometry.size.width > 600 ? .title2 : .title3, design: .rounded))
                        .foregroundColor(.textOnDark.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width > 600 ? 60 : 40)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Custom content based on page type
                    switch page.type {
                    case .welcome, .features, .finale:
                        Spacer()
                            .frame(minHeight: 20, maxHeight: geometry.size.height * 0.2)
                    case .preferences:
                        preferenceSelectionView(geometry: geometry)
                    }
                    
                    // Continue button
                    Button(action: onComplete) {
                        Text(page.buttonText)
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.highlightBackground)
                            )
                            .padding(.horizontal, geometry.size.width > 600 ? 80 : 40)
                    }
                    
                    // Bottom spacer - adaptive
                    Spacer()
                        .frame(minHeight: 40, maxHeight: 80)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    private func preferenceSelectionView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height > 800 ? 30 : 20) {
            // Category selection
            VStack(alignment: .leading, spacing: 15) {
                Text("Choose your interests:")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textOnDark)
                
                let columns = geometry.size.width > 600 ? 
                    Array(repeating: GridItem(.flexible()), count: 4) : 
                    Array(repeating: GridItem(.flexible()), count: 2)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(QuizCategory.allCases, id: \.self) { category in
                        Button(action: {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }) {
                            HStack {
                                Image(systemName: category.icon)
                                    .font(.title3)
                                Text(category.rawValue)
                                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                            }
                            .foregroundColor(selectedCategories.contains(category) ? .black : .textOnDark)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategories.contains(category) ? Color.highlightBackground : Color.white.opacity(0.2))
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, geometry.size.width > 600 ? 60 : 40)
            
            // Difficulty selection
            VStack(alignment: .leading, spacing: 15) {
                Text("Preferred difficulty:")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.textOnDark)
                
                HStack(spacing: 10) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button(action: {
                            selectedDifficulty = difficulty
                        }) {
                            Text(difficulty.rawValue)
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundColor(selectedDifficulty == difficulty ? .black : .textOnDark)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedDifficulty == difficulty ? Color.highlightBackground : Color.white.opacity(0.2))
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, geometry.size.width > 600 ? 60 : 40)
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let buttonText: String
    let type: PageType
    
    enum PageType {
        case welcome
        case features
        case preferences
        case finale
    }
    
    static let allPages = [
        OnboardingPage(
            title: "Welcome to QuizzOne",
            description: "Test your knowledge with engaging quizzes and learn about finance while having fun!",
            icon: "star.fill",
            buttonText: "Get Started",
            type: .welcome
        ),
        OnboardingPage(
            title: "Interactive Learning",
            description: "Explore financial puzzles, entertainment trivia, and mixed challenges designed to educate and entertain.",
            icon: "brain.head.profile",
            buttonText: "Continue",
            type: .features
        ),
        OnboardingPage(
            title: "Customize Your Experience",
            description: "Choose your favorite topics and difficulty level to personalize your quiz experience.",
            icon: "slider.horizontal.3",
            buttonText: "Continue",
            type: .preferences
        ),
        OnboardingPage(
            title: "Ready to Play!",
            description: "Start your first quiz, earn achievements, and climb the leaderboard. Let's begin your learning journey!",
            icon: "trophy.fill",
            buttonText: "Start Quiz",
            type: .finale
        )
    ]
}

#Preview {
    OnboardingView()
}
