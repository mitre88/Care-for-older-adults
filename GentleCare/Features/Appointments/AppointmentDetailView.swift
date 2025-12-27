//
//  AppointmentDetailView.swift
//  GentleCare
//
//  Appointment detail and management
//

import SwiftUI
import SwiftData

struct AppointmentDetailView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    let appointment: MedicalAppointment

    // MARK: - State

    @State private var showingCancelConfirmation = false
    @State private var showingCompleteConfirmation = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: GentleCareTheme.Spacing.lg) {
                        // Header
                        headerSection

                        // Details
                        detailsSection

                        // Preparation
                        if let preparation = appointment.preparationInstructions, !preparation.isEmpty {
                            preparationSection(preparation)
                        }

                        // Notes
                        if let notes = appointment.notes, !notes.isEmpty {
                            notesSection(notes)
                        }

                        // Actions
                        if appointment.status == .scheduled {
                            actionsSection
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Detalles de cita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "4A90D9"))
                }
            }
            .confirmationDialog(
                "Cancelar cita?",
                isPresented: $showingCancelConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancelar cita", role: .destructive) {
                    cancelAppointment()
                }
                Button("No", role: .cancel) {}
            } message: {
                Text("Esta accion no se puede deshacer")
            }
            .confirmationDialog(
                "Marcar como completada?",
                isPresented: $showingCompleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Si, completada") {
                    completeAppointment()
                }
                Button("No", role: .cancel) {}
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Specialty icon
            ZStack {
                Circle()
                    .fill(specialtyColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: appointment.specialty.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(specialtyColor)
            }

            VStack(spacing: 8) {
                Text(appointment.doctorName)
                    .font(GCTypography.headline1)
                    .foregroundStyle(.white)

                Text(appointment.specialty.rawValue)
                    .font(GCTypography.bodyLarge)
                    .foregroundStyle(specialtyColor)

                appointmentStatusBadge
            }
        }
        .padding(.vertical)
    }

    @ViewBuilder
    private var appointmentStatusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: appointmentStatusIcon)
            Text(appointmentStatusText)
        }
        .font(GCTypography.labelMedium)
        .foregroundStyle(appointmentStatusColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(appointmentStatusColor.opacity(0.2))
        }
    }

    private var appointmentStatusIcon: String {
        switch appointment.status {
        case .scheduled: return "clock"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle"
        case .rescheduled: return "arrow.triangle.2.circlepath"
        case .noShow: return "person.fill.xmark"
        }
    }

    private var appointmentStatusText: String {
        switch appointment.status {
        case .scheduled: return "Programada"
        case .completed: return "Completada"
        case .cancelled: return "Cancelada"
        case .rescheduled: return "Reprogramada"
        case .noShow: return "No asistio"
        }
    }

    private var appointmentStatusColor: Color {
        switch appointment.status {
        case .scheduled: return Color(hex: "FF9500")
        case .completed: return Color(hex: "34C759")
        case .cancelled: return Color(hex: "FF6B6B")
        case .rescheduled: return Color(hex: "5AC8FA")
        case .noShow: return Color(hex: "8E8E93")
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        GlassCard(size: .large) {
            VStack(spacing: 16) {
                // Date
                AppointmentDetailRow(
                    icon: "calendar",
                    iconColor: Color(hex: "4A90D9"),
                    title: "Fecha",
                    value: formattedDate
                )

                Divider()
                    .background(Color.white.opacity(0.1))

                // Time
                AppointmentDetailRow(
                    icon: "clock.fill",
                    iconColor: Color(hex: "FF9500"),
                    title: "Hora",
                    value: formattedTime
                )

                Divider()
                    .background(Color.white.opacity(0.1))

                // Location
                AppointmentDetailRow(
                    icon: "mappin.circle.fill",
                    iconColor: Color(hex: "FF6B6B"),
                    title: "Ubicacion",
                    value: appointment.location
                )

                // Time until appointment
                if appointment.status == .scheduled {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    AppointmentDetailRow(
                        icon: "hourglass",
                        iconColor: Color(hex: "5BB381"),
                        title: "Tiempo restante",
                        value: timeUntilAppointment
                    )
                }
            }
        }
    }

    // MARK: - Preparation Section

    private func preparationSection(_ preparation: String) -> some View {
        GlassCard(size: .medium) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "list.clipboard.fill")
                        .foregroundStyle(Color(hex: "AF52DE"))

                    Text("Preparacion")
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)
                }

                Text(preparation)
                    .font(GCTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Notes Section

    private func notesSection(_ notes: String) -> some View {
        GlassCard(size: .medium) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundStyle(Color(hex: "FFB340"))

                    Text("Notas")
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)
                }

                Text(notes)
                    .font(GCTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Quick actions
            HStack(spacing: 12) {
                // Add to calendar
                AppointmentActionButton(
                    icon: "calendar.badge.plus",
                    title: "Calendario",
                    color: Color(hex: "4A90D9")
                ) {
                    GCHaptic.medium.trigger()
                }

                // Get directions
                AppointmentActionButton(
                    icon: "map.fill",
                    title: "Direcciones",
                    color: Color(hex: "5BB381")
                ) {
                    openMaps()
                }

                // Call
                AppointmentActionButton(
                    icon: "phone.fill",
                    title: "Llamar",
                    color: Color(hex: "34C759")
                ) {
                    GCHaptic.medium.trigger()
                }
            }

            // Status actions
            GlassButton(
                "Marcar como completada",
                icon: "checkmark.circle",
                style: .success,
                size: .large
            ) {
                showingCompleteConfirmation = true
            }

            GlassButton(
                "Cancelar cita",
                icon: "xmark.circle",
                style: .destructive,
                size: .large
            ) {
                showingCancelConfirmation = true
            }
        }
    }

    // MARK: - Computed Properties

    private var specialtyColor: Color {
        switch appointment.specialty {
        case .generalPractitioner: return Color(hex: "4A90D9")
        case .cardiologist: return Color(hex: "FF6B6B")
        case .neurologist: return Color(hex: "AF52DE")
        case .orthopedist: return Color(hex: "FF9500")
        case .ophthalmologist: return Color(hex: "5AC8FA")
        case .dermatologist: return Color(hex: "E8846B")
        case .geriatrician: return Color(hex: "5BB381")
        case .psychiatrist: return Color(hex: "BF5AF2")
        case .endocrinologist: return Color(hex: "FFB340")
        default: return Color(hex: "8E8E93")
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d 'de' MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: appointment.appointmentDate).capitalized
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: appointment.appointmentDate)
    }

    private var timeUntilAppointment: String {
        let now = Date()
        let interval = appointment.appointmentDate.timeIntervalSince(now)

        if interval < 0 {
            return "Pasada"
        }

        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

        if days > 0 {
            return "\(days) dia\(days > 1 ? "s" : ""), \(hours) hora\(hours > 1 ? "s" : "")"
        } else if hours > 0 {
            return "\(hours) hora\(hours > 1 ? "s" : ""), \(minutes) min"
        } else {
            return "\(minutes) minutos"
        }
    }

    // MARK: - Actions

    private func cancelAppointment() {
        appointment.status = .cancelled
        try? modelContext.save()
        GCHaptic.warning.trigger()
        dismiss()
    }

    private func completeAppointment() {
        appointment.status = .completed
        try? modelContext.save()
        GCHaptic.success.trigger()
        dismiss()
    }

    private func openMaps() {
        let query = appointment.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(query)") {
            UIApplication.shared.open(url)
        }
        GCHaptic.medium.trigger()
    }
}

// MARK: - Appointment Detail Row

struct AppointmentDetailRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GCTypography.labelSmall)
                    .foregroundStyle(.white.opacity(0.5))

                Text(value)
                    .font(GCTypography.bodyLarge)
                    .foregroundStyle(.white)
            }

            Spacer()
        }
    }
}

// MARK: - Appointment Action Button

struct AppointmentActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)

                Text(title)
                    .font(GCTypography.captionMedium)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCard()
        }
    }
}

// MARK: - Preview

#Preview("Appointment Detail") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MedicalAppointment.self, configurations: config)

    let appointment = MedicalAppointment(
        title: "Control cardiologico",
        doctorName: "Dr. Maria Garcia",
        specialty: .cardiologist,
        location: "Hospital Central, Consultorio 305",
        appointmentDate: Date().addingTimeInterval(86400)
    )
    appointment.notes = "Llevar resultados de laboratorio"
    appointment.preparationInstructions = "Ayuno de 8 horas antes de la cita"

    return AppointmentDetailView(appointment: appointment)
        .modelContainer(container)
}
