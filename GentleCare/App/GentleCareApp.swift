//
//  GentleCareApp.swift
//  GentleCare
//
//  Elderly Care iOS App with Hybrid AI
//

import SwiftUI
import SwiftData

@main
struct GentleCareApp: App {

    // MARK: - State

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // MARK: - Model Container

    private let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        do {
            modelContainer = try ModelContainer.createShared()
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    AppTabView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(.dark)
            .tint(Color.gcPrimary)
        }
        .modelContainer(modelContainer)
    }
}
