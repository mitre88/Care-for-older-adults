//
//  DashboardView.swift
//  GentleCare
//
//  Main dashboard showing daily overview for elderly care
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ElderlyProfile]
    @Query(sort: \Medication.name) private var medications: [Medication]
    @Query(sort: \MedicalAppointment.appointmentDate) private var appointments: [MedicalAppointment]
    @Query(sort: \VitalSign.measuredAt, order: .reverse) private var vitalSigns: [VitalSign]

    // MARK: - State

    @State private var showingAddMedication = false
    @State private var showingAddVital = false
    @State private var showingEmergency = false

    // MARK: - Computed Properties

    private var profile: ElderlyProfile? {
        profiles.first
    }

    private var activeMedications: [Medication] {
        medications.filter { $0.isActive }
    }

    private var upcomingAppointments: [MedicalAppointment] {
        appointments.filter { $0.isUpcoming }.prefix(3).map { $0 }
    }

    private var latestVitals: [VitalSign] {
        var latest: [VitalSign] = []
        var seenTypes: Set<VitalSignType> = []

        for vital in vitalSigns {
            if !seenTypes.contains(vital.type) {
                latest.append(vital)
                seenTypes.insert(vital.type)
            }
            if latest.count >= 4 { break }
        }

        return latest
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buenos dias"
        case 12..<18: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: GentleCareTheme.Spacing.lg) {
                // Header
                headerSection

                // Quick Actions
                quickActionsSection

                // Next Medication
                if let nextMed = activeMedications.first(where: { $0.nextScheduledTime != nil }) {
                    nextMedicationCard(nextMed)
                }

                // Vitals Overview
                if !latestVitals.isEmpty {
                    vitalsSection
                }

                // Upcoming Appointments
                if !upcomingAppointments.isEmpty {
                    appointmentsSection
                }

                // Emergency Button
                emergencyButton
            }
            .padding()
        }
        .background(Color(hex: "1C1C1E"))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView()
        }
        .sheet(isPresented: $showingAddVital) {
            AddVitalReadingView()
        }
        .sheet(isPresented: $showingEmergency) {
            EmergencyView()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(GCTypography.headline3)
                .foregroundStyle(.white.opacity(0.7))

            Text(profile?.firstName ?? "Bienvenido")
                .font(GCTypography.displaySmall)
                .foregroundStyle(.white)

            Text(formattedDate)
                .font(GCTypography.bodyMedium)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, GentleCareTheme.Spacing.md)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        formatter.locale = Locale(identifier: "es")
        return formatter.string(from: Date()).capitalized
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones rapidas")
                .font(GCTypography.titleMedium)
                .foregroundStyle(.white)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Agregar\nMedicamento",
                    icon: "pills.fill",
                    color: Color(hex: "4A90D9")
                ) {
                    showingAddMedication = true
                }

                QuickActionCard(
                    title: "Registrar\nSignos Vitales",
                    icon: "heart.text.square.fill",
                    color: Color(hex: "FF6B6B")
                ) {
                    showingAddVital = true
                }

                QuickActionCard(
                    title: "Nueva\nCita",
                    icon: "calendar.badge.plus",
                    color: Color(hex: "5BB381")
                ) {
                    // TODO: Show add appointment
                }

                QuickActionCard(
                    title: "Llamar\nEmergencia",
                    icon: "phone.fill",
                    color: Color(hex: "FF9500")
                ) {
                    showingEmergency = true
                }
            }
        }
    }

    // MARK: - Next Medication Card

    private func nextMedicationCard(_ medication: Medication) -> some View {
        GlassCard(size: .large, isInteractive: true) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: "4A90D9"))

                    Text("Proximo medicamento")
                        .font(GCTypography.labelLarge)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    if let time = medication.timeUntilNextDose {
                        Text(time)
                            .font(GCTypography.labelMedium)
                            .foregroundStyle(Color(hex: "FFB340"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(Color(hex: "FFB340").opacity(0.2))
                            }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(GCTypography.headline2)
                        .foregroundStyle(.white)

                    Text(medication.formattedDosage)
                        .font(GCTypography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.7))
                }

                GlassButton(
                    "Marcar como tomado",
                    icon: "checkmark",
                    style: .success,
                    size: .large
                ) {
                    // TODO: Mark as taken
                    GCHaptic.success.trigger()
                }
            }
        }
    }

    // MARK: - Vitals Section

    private var vitalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Signos vitales")
                    .font(GCTypography.titleMedium)
                    .foregroundStyle(.white)

                Spacer()

                Button("Ver todo") {
                    // Navigate to vitals
                }
                .font(GCTypography.labelMedium)
                .foregroundStyle(Color(hex: "4A90D9"))
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(latestVitals, id: \.id) { vital in
                    VitalMiniCard(vital: vital)
                }
            }
        }
    }

    // MARK: - Appointments Section

    private var appointmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Proximas citas")
                    .font(GCTypography.titleMedium)
                    .foregroundStyle(.white)

                Spacer()

                Button("Ver todo") {
                    // Navigate to appointments
                }
                .font(GCTypography.labelMedium)
                .foregroundStyle(Color(hex: "4A90D9"))
            }

            ForEach(upcomingAppointments, id: \.id) { appointment in
                AppointmentMiniCard(appointment: appointment)
            }
        }
    }

    // MARK: - Emergency Button

    private var emergencyButton: some View {
        GlassButton(
            "Emergencia",
            icon: "sos",
            style: .destructive,
            size: .extraLarge
        ) {
            showingEmergency = true
            GCHaptic.warning.trigger()
        }
        .padding(.top, GentleCareTheme.Spacing.lg)
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {

    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            GCHaptic.light.trigger()
            action()
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)

                Text(title)
                    .font(GCTypography.labelMedium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .glassCard()
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Vital Mini Card

struct VitalMiniCard: View {

    let vital: VitalSign

    var body: some View {
        GlassCard(size: .small) {
            HStack {
                Image(systemName: vital.type.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(vital.formattedValue)
                        .font(GCTypography.titleLarge)
                        .foregroundStyle(.white)

                    Text(vital.type.rawValue)
                        .font(GCTypography.captionMedium)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer()
            }
        }
    }

    private var statusColor: Color {
        switch vital.status {
        case .low: return Color(hex: "5AC8FA")
        case .normal: return Color(hex: "34C759")
        case .high: return Color(hex: "FF6B6B")
        }
    }
}

// MARK: - Appointment Mini Card

struct AppointmentMiniCard: View {

    let appointment: MedicalAppointment

    var body: some View {
        GlassCard(size: .medium, isInteractive: true) {
            HStack(spacing: 16) {
                // Date badge
                VStack(spacing: 2) {
                    Text(dayOfMonth)
                        .font(GCTypography.numericSmall)
                        .foregroundStyle(.white)

                    Text(monthAbbr)
                        .font(GCTypography.captionMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(width: 50, height: 50)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "4A90D9").opacity(0.3))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.doctorName)
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)

                    Text(appointment.specialty.rawValue)
                        .font(GCTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(appointment.formattedTime)
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(Color(hex: "4A90D9"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: appointment.appointmentDate)
    }

    private var monthAbbr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "es")
        return formatter.string(from: appointment.appointmentDate).uppercased()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(try! ModelContainer.createPreview())
}
