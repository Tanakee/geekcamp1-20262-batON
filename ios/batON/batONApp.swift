//
//  batONApp.swift
//  batON
//
//  Created by 田中渓都 on 2026/03/11.
//

import SwiftUI

@main
struct batONApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.batCard)
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().tintColor = UIColor(Color.batPrimary)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.batTextSecondary)
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
