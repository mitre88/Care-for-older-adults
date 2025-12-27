//
//  AppointmentsView.swift
//  GentleCare
//
//  Medical appointments management
//

import SwiftUI
import SwiftData

struct AppointmentsView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MedicalAppointment.dateTime) private var appointments: [MedicalAppointment]

    // MARK: - State

    @State private var showingAddAppointment = false
    @State private var selectedFilter: AppointmentFilter = .upcoming
    @State private var selectedAppointment: MedicalAppointment?

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(hex: "1C1C1E")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Filter tabs
                filterTabs

                if filteredAppointments.isEmpty {
                    emptyState
                } else {
                    appointmentsList
                }
            }
        }
        .navigationTitle("Citas medicas")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddAppointment = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(hex: "4A90D9"))
                }
            }
        }
        .sheet(isPresented: $showingAddAppointment) {
            AddAppointmentView()
        }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailView(appointment: appointment)
        }
    }

    // MARK: - Filter Tabs

    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppointmentFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        isSelected: selectedFilter == filter,
                        count: count(for: filter)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                        GCHaptic.selection.trigger()
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: GentleCareTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 70))
                .foregroundStyle(Color(hex: "4A90D9").opacity(0.5))

            VStack(spacing: 8) {
                Text("Sin citas programadas")
                    .font(GCTypography.headline2)
                    .foregroundStyle(.white)

                Text("Agrega tu primera cita medica")
                    .font(GCTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.6))
            }

            GlassButton(
                "Agregar cita",
                icon: "plus",
                style: .primary,
                isFullWidth: false
            ) {
                showingAddAppointment = true
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Appointments List

    private var appointmentsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(groupedAppointments.keys.sorted(), id: \.self) { date in
                    if let dayAppointments = groupedAppointments[date] {
                        Section {
                            ForEach(dayAppointments, id: \.id) { appointment in
                                AppointmentCard(appointment: appointment) {
                                    selectedAppointment = appointment
                                }
                            }
                        } header: {
                            HStack {
                                Text(formatSectionDate(date))
                                    .font(GCTypography.labelMedium)
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Computed Properties

    private var filteredAppointments: [MedicalAppointment] {
        let now = Date()
        switch selectedFilter {
        case .upcoming:
            return appointments.filter { $0.dateTime >= now && $0.status != .cancelled }
        case .past:
            return appointments.filter { $0.dateTime < now || $0.status == .completed }
        case .all:
            return appointments
        }
    }

    private var groupedAppointments: [Date: [MedicalAppointment]] {
        Dictionary(grouping: filteredAppointments) { appointment in
            Calendar.current.startOfDay(for: appointment.dateTime)
        }
    }

    private func count(for filter: AppointmentFilter) -> Int {
        let now = Date()
        switch filter {
        case .upcoming:
            return appointments.filter { $0.dateTime >= now && $0.status != .cancelled }.count
        case .past:
            return appointments.filter { $0.dateTime < now || $0.status == .completed }.count
        case .all:
            return appointments.count
        }
    }

    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")

        if Calendar.current.isDateInToday(date) {
            return "Hoy"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Manana"
        } else {
            formatter.dateFormat = "EEEE, d 'de' MMMM"
            return formatter.string(from: date).capitalized
        }
    }
}

// MARK: - Appointment Filter

enum AppointmentFilter: CaseIterable {
    case upcoming
    case past
    case all

    var title: String {
        switch self {
        case .upcoming: return "Proximas"
        case .past: return "Pasadas"
        case .all: return "Todas"
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(GCTypography.labelMedium)

                if count > 0 {
                    Text("\(count)")
                        .font(GCTypography.captionSmall)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background {
                            Capsule()
                                .fill(.white.opacity(0.2))
                        }
                }
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(isSelected ? Color(hex: "4A90D9") : Color.white.opacity(0.1))
            }
        }
    }
}

// MARK: - Appointment Card

struct AppointmentCard: View {
    let appointment: MedicalAppointment
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GlassCard(size: .medium) {
                HStack(spacing: 16) {
                    // Time indicator
                    VStack(spacing: 4) {
                        Text(formattedTime)
                            .font(GCTypography.titleMedium)
                            .foregroundStyle(.white)

                        Text(formattedDate)
                            .font(GCTypography.captionSmall)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(width: 60)

                    // Divider
                    Rectangle()
                        .fill(specialtyColor.opacity(0.5))
                        .frame(width: 3)
                        .clipShape(Capsule())

                    // Details
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(appointment.specialty.rawValue)
                                .font(GCTypography.labelSmall)
                                .foregroundStyle(specialtyColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .fill(specialtyColor.opacity(0.2))
                                }

                            Spacer()

                            statusBadge
                        }

                        Text(appointment.doctorName)
                            .font(GCTypography.titleMedium)
                            .foregroundStyle(.white)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12))
                            Text(appointment.location)
                                .font(GCTypography.bodySmall)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: appointment.dateTime)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: appointment.dateTime)
    }

    private var specialtyColor: Color {
        switch appointment.specialty {
        case .generalMedicine: return Color(hex: "4A90D9")
        case .cardiology: return Color(hex: "FF6B6B")
        case .neurology: return Color(hex: "AF52DE")
        case .orthopedics: return Color(hex: "FF9500")
        case .ophthalmology: return Color(hex: "5AC8FA")
        case .dermatology: return Color(hex: "E8846B")
        case .geriatrics: return Color(hex: "5BB381")
        case .psychiatry: return Color(hex: "BF5AF2")
        case .endocrinology: return Color(hex: "FFB340")
        case .other: return Color(hex: "8E8E93")
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch appointment.status {
        case .scheduled:
            EmptyView()
        case .confirmed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(hex: "34C759"))
        case .completed:
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color(hex: "5AC8FA"))
        case .cancelled:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(Color(hex: "FF6B6B"))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AppointmentsView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(try! ModelContainer.createPreview())
}
