//
//  AppTabView.swift
//  GentleCare
//
//  Main tab navigation with Liquid Glass styling
//

import SwiftUI

// MARK: - App Tab View

struct AppTabView: View {

    // MARK: - State

    @State private var selectedTab: Tab = .home
    @State private var tabBarVisible = true

    // MARK: - Tabs

    enum Tab: String, CaseIterable, Identifiable {
        case home = "Inicio"
        case medications = "Medicamentos"
        case vitals = "Salud"
        case settings = "Ajustes"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .medications: return "pills.fill"
            case .vitals: return "heart.fill"
            case .settings: return "gearshape.fill"
            }
        }

        var selectedIcon: String {
            icon
        }
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases) { tab in
                NavigationStack {
                    destinationView(for: tab)
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .tint(Color(hex: "4A90D9"))
    }

    // MARK: - Destination Views

    @ViewBuilder
    private func destinationView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            DashboardView()
        case .medications:
            MedicationListView()
        case .vitals:
            VitalSignsView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Navigation Destinations

enum NavigationDestination: Hashable {
    case medicationDetail(Medication)
    case addMedication
    case medicationSchedule(Medication)
    case vitalHistory(VitalSignType)
    case addVitalReading(VitalSignType?)
    case appointmentDetail(MedicalAppointment)
    case addAppointment
    case emergency
    case emergencyContacts
    case profileEdit
    case notificationSettings
    case aboutApp
}

// MARK: - Preview

#Preview {
    AppTabView()
        .preferredColorScheme(.dark)
}
