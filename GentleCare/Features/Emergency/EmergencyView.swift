//
//  EmergencyView.swift
//  GentleCare
//
//  Emergency contacts and SOS functionality
//

import SwiftUI
import SwiftData

struct EmergencyView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EmergencyContact.order) private var contacts: [EmergencyContact]

    // MARK: - State

    @State private var showingAddContact = false
    @State private var callConfirmation: EmergencyContact?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: GentleCareTheme.Spacing.lg) {
                        // SOS Button
                        sosButton

                        // Emergency services
                        emergencyServicesSection

                        // Personal contacts
                        if !contacts.isEmpty {
                            personalContactsSection
                        }

                        // Add contact button
                        GlassButton(
                            "Agregar contacto",
                            icon: "person.badge.plus",
                            style: .secondary,
                            size: .large
                        ) {
                            showingAddContact = true
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Emergencia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "4A90D9"))
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddEmergencyContactView()
            }
            .confirmationDialog(
                "Llamar a \(callConfirmation?.name ?? "")?",
                isPresented: .constant(callConfirmation != nil),
                titleVisibility: .visible
            ) {
                if let contact = callConfirmation, let url = contact.callURL {
                    Button("Llamar") {
                        UIApplication.shared.open(url)
                        callConfirmation = nil
                    }
                }
                Button("Cancelar", role: .cancel) {
                    callConfirmation = nil
                }
            }
        }
    }

    // MARK: - SOS Button

    private var sosButton: some View {
        Button {
            // Call emergency services
            GCHaptic.heavy.trigger()
            if let url = URL(string: "tel://911") {
                UIApplication.shared.open(url)
            }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF6B6B"))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "FF6B6B").opacity(0.5), radius: 20, x: 0, y: 10)

                    Text("SOS")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Presiona para llamar a emergencias")
                    .font(GCTypography.labelMedium)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.vertical, GentleCareTheme.Spacing.lg)
    }

    // MARK: - Emergency Services

    private var emergencyServicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Servicios de emergencia")
                .font(GCTypography.titleMedium)
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                EmergencyServiceButton(
                    title: "Emergencias",
                    number: "911",
                    icon: "phone.fill",
                    color: Color(hex: "FF6B6B")
                )

                EmergencyServiceButton(
                    title: "Policia",
                    number: "911",
                    icon: "shield.fill",
                    color: Color(hex: "4A90D9")
                )

                EmergencyServiceButton(
                    title: "Bomberos",
                    number: "911",
                    icon: "flame.fill",
                    color: Color(hex: "FF9500")
                )
            }
        }
    }

    // MARK: - Personal Contacts

    private var personalContactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contactos personales")
                .font(GCTypography.titleMedium)
                .foregroundStyle(.white)

            ForEach(contacts, id: \.id) { contact in
                EmergencyContactCard(contact: contact) {
                    callConfirmation = contact
                    GCHaptic.medium.trigger()
                }
            }
        }
    }
}

// MARK: - Emergency Service Button

struct EmergencyServiceButton: View {
    let title: String
    let number: String
    let icon: String
    let color: Color

    var body: some View {
        Button {
            if let url = URL(string: "tel://\(number)") {
                GCHaptic.medium.trigger()
                UIApplication.shared.open(url)
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(color)

                Text(title)
                    .font(GCTypography.labelSmall)
                    .foregroundStyle(.white)

                Text(number)
                    .font(GCTypography.captionSmall)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCard()
        }
    }
}

// MARK: - Emergency Contact Card

struct EmergencyContactCard: View {
    let contact: EmergencyContact
    let onCall: () -> Void

    var body: some View {
        GlassCard(size: .medium) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "4A90D9").opacity(0.2))
                        .frame(width: 50, height: 50)

                    Text(contact.initials)
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(contact.name)
                            .font(GCTypography.titleMedium)
                            .foregroundStyle(.white)

                        if contact.isPrimary {
                            Text("Principal")
                                .font(GCTypography.captionSmall)
                                .foregroundStyle(Color(hex: "4A90D9"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .fill(Color(hex: "4A90D9").opacity(0.2))
                                }
                        }
                    }

                    Text(contact.relationship)
                        .font(GCTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.6))

                    Text(contact.formattedPhone)
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(Color(hex: "4A90D9"))
                }

                Spacer()

                // Call button
                Button(action: onCall) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background {
                            Circle()
                                .fill(Color(hex: "34C759"))
                        }
                }
            }
        }
    }
}

// MARK: - Emergency Contacts View

struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EmergencyContact.order) private var contacts: [EmergencyContact]

    @State private var showingAddContact = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                if contacts.isEmpty {
                    emptyState
                } else {
                    contactsList
                }
            }
            .navigationTitle("Contactos de emergencia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddContact = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color(hex: "4A90D9"))
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddEmergencyContactView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: GentleCareTheme.Spacing.lg) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "4A90D9").opacity(0.5))

            Text("Sin contactos de emergencia")
                .font(GCTypography.headline2)
                .foregroundStyle(.white)

            Text("Agrega contactos para situaciones de emergencia")
                .font(GCTypography.bodyMedium)
                .foregroundStyle(.white.opacity(0.6))

            GlassButton("Agregar contacto", icon: "plus", style: .primary, isFullWidth: false) {
                showingAddContact = true
            }
        }
        .padding()
    }

    private var contactsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(contacts, id: \.id) { contact in
                    EmergencyContactCard(contact: contact) {
                        if let url = contact.callURL {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Add Emergency Contact View

struct AddEmergencyContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ElderlyProfile]

    @State private var name = ""
    @State private var relationship = ""
    @State private var phoneNumber = ""
    @State private var isPrimary = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: GentleCareTheme.Spacing.lg) {
                        GlassTextField(
                            "Nombre",
                            placeholder: "Nombre completo",
                            text: $name,
                            icon: "person.fill"
                        )

                        GlassTextField(
                            "Relacion",
                            placeholder: "Ej: Hijo, Hija, Vecino",
                            text: $relationship,
                            icon: "heart.fill"
                        )

                        GlassTextField(
                            "Telefono",
                            placeholder: "+1 555-123-4567",
                            text: $phoneNumber,
                            icon: "phone.fill",
                            keyboardType: .phonePad
                        )

                        // Primary toggle
                        GlassCard(size: .small) {
                            Toggle(isOn: $isPrimary) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(Color(hex: "FFB340"))

                                    Text("Contacto principal")
                                        .font(GCTypography.bodyLarge)
                                        .foregroundStyle(.white)
                                }
                            }
                            .tint(Color(hex: "4A90D9"))
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }

                VStack {
                    Spacer()

                    GlassButton(
                        "Guardar contacto",
                        icon: "checkmark",
                        style: .primary,
                        isDisabled: !isValid
                    ) {
                        saveContact()
                    }
                    .padding()
                }
            }
            .navigationTitle("Nuevo contacto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !relationship.isEmpty && !phoneNumber.isEmpty
    }

    private func saveContact() {
        let contact = EmergencyContact(
            name: name,
            relationship: relationship,
            phoneNumber: phoneNumber,
            isPrimary: isPrimary,
            profile: profiles.first
        )

        modelContext.insert(contact)

        do {
            try modelContext.save()
            GCHaptic.success.trigger()
            dismiss()
        } catch {
            GCHaptic.error.trigger()
        }
    }
}

// MARK: - Preview

#Preview {
    EmergencyView()
        .modelContainer(try! ModelContainer.createPreview())
}
