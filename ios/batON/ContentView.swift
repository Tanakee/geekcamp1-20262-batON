//
//  ContentView.swift
//  batON
//
//  Created by 田中渓都 on 2026/03/11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            NavigationView { DashboardView() }
                .tabItem { Label("ホーム", systemImage: "house.fill") }

            ActivityListView()
                .tabItem { Label("活動", systemImage: "sparkles") }

            BenefactorListView()
                .tabItem { Label("恩人", systemImage: "heart.fill") }

            ReportListView()
                .tabItem { Label("報告", systemImage: "envelope.fill") }

            ProfileView()
                .tabItem { Label("プロフィール", systemImage: "person.fill") }
        }
        .environmentObject(appViewModel)
        .onAppear {
            appViewModel.loadFromAPI(userId: authViewModel.currentUserId)
        }
    }
}

#Preview {
    ContentView()
}
