//
//  MainTabView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var quizService = QuizService()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(quizService)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            QuizListView()
                .environmentObject(quizService)
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Quizzes")
                }
            
            LeaderboardView()
                .environmentObject(quizService)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }
            
            FinancialTipsView()
                .environmentObject(quizService)
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Tips")
                }
            
            ProfileView()
                .environmentObject(quizService)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.primaryButton)
    }
}

#Preview {
    MainTabView()
}
