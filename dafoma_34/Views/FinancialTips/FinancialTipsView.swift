//
//  FinancialTipsView.swift
//  QuizzOne
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct FinancialTipsView: View {
    @EnvironmentObject var quizService: QuizService
    @State private var selectedCategory = "All"
    
    private var categories: [String] {
        let allCategories = quizService.financialTips.map { $0.category }
        return ["All"] + Array(Set(allCategories)).sorted()
    }
    
    private var filteredTips: [FinancialTip] {
        if selectedCategory == "All" {
            return quizService.financialTips.sorted { $0.date > $1.date }
        } else {
            return quizService.financialTips
                .filter { $0.category == selectedCategory }
                .sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Today's tip highlight
                if let todaysTip = quizService.getTodaysTip() {
                    todaysTipSection(todaysTip)
                }
                
                // Category filter
                categoryFilter
                
                // Tips list
                tipsListView
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Financial Tips")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func todaysTipSection(_ tip: FinancialTip) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Today's Tip")
                    .font(.system(.headline, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.highlightBackground)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            NavigationLink(destination: FinancialTipDetailView(tip: tip)) {
                TodaysTipCard(tip: tip)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.system(.subheadline, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.medium))
                            .foregroundColor(selectedCategory == category ? .white : .textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.primaryButton : Color(.systemBackground))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var tipsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredTips) { tip in
                    NavigationLink(destination: FinancialTipDetailView(tip: tip)) {
                        FinancialTipCard(tip: tip)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

struct TodaysTipCard: View {
    let tip: FinancialTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tip.category)
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primaryButton)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primaryButton.opacity(0.1))
                    )
                
                Spacer()
                
                Text("\(tip.readingTime) min read")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            Text(tip.title)
                .font(.system(.title3, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
            
            Text(tip.content)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text("Today")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Read more")
                        .font(.system(.caption, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.medium))
                        .foregroundColor(.primaryButton)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.primaryButton)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.highlightBackground.opacity(0.1), Color.primaryButton.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.highlightBackground.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FinancialTipCard: View {
    let tip: FinancialTip
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(tip.date)
    }
    
    private var dateText: String {
        if isToday {
            return "Today"
        } else if Calendar.current.isDateInYesterday(tip.date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: tip.date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tip.category)
                    .font(.system(.caption, design: .rounded))
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primaryButton)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primaryButton.opacity(0.1))
                    )
                
                Spacer()
                
                Text("\(tip.readingTime) min read")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            Text(tip.title)
                .font(.system(.headline, design: .rounded))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
            
            Text(tip.content)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(dateText)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .cardStyle()
    }
}

struct FinancialTipDetailView: View {
    let tip: FinancialTip
    @Environment(\.presentationMode) var presentationMode
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: tip.date)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(tip.category)
                            .font(.system(.caption, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundColor(.primaryButton)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryButton.opacity(0.1))
                            )
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("\(tip.readingTime) min read")
                                .font(.system(.caption, design: .rounded))
                        }
                        .foregroundColor(.textSecondary)
                    }
                    
                    Text(tip.title)
                        .font(.system(.largeTitle, design: .rounded))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(dateText)
                            .font(.system(.caption, design: .rounded))
                    }
                    .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    Text(tip.content)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                    
                    // Additional content sections could be added here
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Takeaways")
                            .font(.system(.headline, design: .rounded))
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundColor(.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            takeawayPoint("Start with small, manageable amounts")
                            takeawayPoint("Consistency is more important than perfection")
                            takeawayPoint("Always do your research before making decisions")
                        }
                    }
                    .padding(16)
                    .background(Color.highlightBackground.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    private func takeawayPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.primaryButton)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    FinancialTipsView()
        .environmentObject(QuizService())
}

