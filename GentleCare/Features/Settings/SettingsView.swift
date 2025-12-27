//
//  SettingsView.swift
//  GentleCare
//
//  App settings and profile management
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ElderlyProfile]
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    // MARK: - State

    @State private var showingEditProfile = false
    @State private var showingEmergencyContacts = false
    @State private var showingAbout = false

    private var profile: ElderlyProfile? {
        profiles.first
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(hex: "1C1C1E")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: GentleCareTheme.Spacing.lg) {
                    // Profile section
                    profileSection

                    // Settings groups
                    settingsGroup(title: "Preferencias") {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Notificaciones",
                            color: Color(hex: "FF9500")
                        ) {
                            // Notifications settings
                        }

                        SettingsRow(
                            icon: "textformat.size",
                            title: "Accesibilidad",
                            color: Color(hex: "5AC8FA")
                        ) {
                            // Accessibility
                        }
                    }

                    settingsGroup(title: "Seguridad") {
                        SettingsRow(
                            icon: "person.2.fill",
                            title: "Contactos de emergencia",
                            color: Color(hex: "FF6B6B")
                        ) {
                            showingEmergencyContacts = true
                        }

                        SettingsRow(
                            icon: "lock.shield.fill",
                            title: "Privacidad",
                            color: Color(hex: "34C759")
                        ) {
                            // Privacy
                        }
                    }

                    settingsGroup(title: "Datos") {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "Exportar datos",
                            color: Color(hex: "4A90D9")
                        ) {
                            // Export
                        }

                        SettingsRow(
                            icon: "trash.fill",
                            title: "Eliminar todos los datos",
                            color: Color(hex: "FF6B6B"),
                            isDestructive: true
                        ) {
                            // Delete data
                        }
                    }

                    settingsGroup(title: "Informacion") {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "Acerca de GentleCare",
                            color: Color(hex: "8E8E93")
                        ) {
                            showingAbout = true
                        }

                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Ayuda y soporte",
                            color: Color(hex: "5AC8FA")
                        ) {
                            // Help
                        }
                    }

                    // Version
                    Text("Version 1.0.0")
                        .font(GCTypography.captionMedium)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle("Ajustes")
        .sheet(isPresented: $showingEditProfile) {
            if let profile {
                EditProfileView(profile: profile)
            }
        }
        .sheet(isPresented: $showingEmergencyContacts) {
            EmergencyContactsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        GlassCard(size: .large, isInteractive: true) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "4A90D9").opacity(0.2))
                        .frame(width: 70, height: 70)

                    if let profile {
                        Text(profile.initials)
                            .font(GCTypography.headline1)
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(hex: "4A90D9"))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile?.fullName ?? "Configurar perfil")
                        .font(GCTypography.headline2)
                        .foregroundStyle(.white)

                    if let profile {
                        Text("\(profile.age) anos")
                            .font(GCTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .onTapGesture {
            showingEditProfile = true
        }
    }

    // MARK: - Settings Group

    @ViewBuilder
    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 4)

            GlassCard(size: .medium, content: content)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.2))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(isDestructive ? Color(hex: "FF6B6B") : .white)

                    if let subtitle {
                        Text(subtitle)
                            .font(GCTypography.captionMedium)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let profile: ElderlyProfile

    @State private var firstName: String = ""
    @State private var lastName: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: GentleCareTheme.Spacing.lg) {
                        GlassTextField(
                            "Nombre",
                            placeholder: "Nombre",
                            text: $firstName,
                            icon: "person.fill"
                        )

                        GlassTextField(
                            "Apellido",
                            placeholder: "Apellido",
                            text: $lastName,
                            icon: "person.fill"
                        )

                        GlassButton("Guardar cambios", icon: "checkmark", style: .primary) {
                            saveChanges()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
            .onAppear {
                firstName = profile.firstName
                lastName = profile.lastName
            }
        }
    }

    private func saveChanges() {
        profile.firstName = firstName
        profile.lastName = lastName
        profile.updateTimestamp()
        try? modelContext.save()
        GCHaptic.success.trigger()
        dismiss()
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                VStack(spacing: GentleCareTheme.Spacing.xl) {
                    Spacer()

                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color(hex: "4A90D9"))

                    VStack(spacing: 8) {
                        Text("GentleCare")
                            .font(GCTypography.displaySmall)
                            .foregroundStyle(.white)

                        Text("Version 1.0.0")
                            .font(GCTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Text("Tu companero de cuidado con inteligencia artificial")
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()

                    VStack(spacing: 8) {
                        Text("Desarrollado con amor para el cuidado de nuestros mayores")
                            .font(GCTypography.captionMedium)
                            .foregroundStyle(.white.opacity(0.5))

                        Text("2024 GentleCare")
                            .font(GCTypography.captionMedium)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding()
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "4A90D9"))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(try! ModelContainer.createPreview())
}
