//
//  AddAppointmentView.swift
//  GentleCare
//
//  Add new medical appointment
//

import SwiftUI
import SwiftData

struct AddAppointmentView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ElderlyProfile]

    // MARK: - State

    @State private var doctorName = ""
    @State private var specialty: MedicalSpecialty = .generalMedicine
    @State private var location = ""
    @State private var dateTime = Date().addingTimeInterval(86400) // Tomorrow
    @State private var notes = ""
    @State private var preparationInstructions = ""
    @State private var enableReminder = true
    @State private var reminderMinutes = 60

    @State private var currentStep = 0

    private let reminderOptions = [15, 30, 60, 120, 1440] // minutes

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator

                    // Content
                    TabView(selection: $currentStep) {
                        doctorStep.tag(0)
                        dateTimeStep.tag(1)
                        detailsStep.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(response: 0.4), value: currentStep)

                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationTitle("Nueva cita")
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

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color(hex: "4A90D9") : Color.white.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .padding()
    }

    // MARK: - Step 1: Doctor Info

    private var doctorStep: some View {
        ScrollView {
            VStack(spacing: GentleCareTheme.Spacing.lg) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "4A90D9"))

                    Text("Informacion del medico")
                        .font(GCTypography.headline2)
                        .foregroundStyle(.white)

                    Text("Ingresa los datos del profesional")
                        .font(GCTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, GentleCareTheme.Spacing.xl)

                // Doctor name
                GlassTextField(
                    "Nombre del doctor",
                    placeholder: "Dr. Juan Perez",
                    text: $doctorName,
                    icon: "person.fill"
                )

                // Specialty selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Especialidad")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(MedicalSpecialty.allCases, id: \.self) { spec in
                            SpecialtyChip(
                                specialty: spec,
                                isSelected: specialty == spec
                            ) {
                                specialty = spec
                                GCHaptic.selection.trigger()
                            }
                        }
                    }
                }

                // Location
                GlassTextField(
                    "Ubicacion",
                    placeholder: "Hospital Central, Consultorio 305",
                    text: $location,
                    icon: "mappin.circle.fill"
                )
            }
            .padding()
        }
    }

    // MARK: - Step 2: Date & Time

    private var dateTimeStep: some View {
        ScrollView {
            VStack(spacing: GentleCareTheme.Spacing.lg) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "5BB381"))

                    Text("Fecha y hora")
                        .font(GCTypography.headline2)
                        .foregroundStyle(.white)

                    Text("Selecciona cuando es la cita")
                        .font(GCTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, GentleCareTheme.Spacing.xl)

                // Date picker
                GlassCard(size: .large) {
                    DatePicker(
                        "Fecha y hora",
                        selection: $dateTime,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color(hex: "4A90D9"))
                    .colorScheme(.dark)
                }

                // Reminder toggle
                GlassCard(size: .small) {
                    Toggle(isOn: $enableReminder) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(Color(hex: "FF9500"))

                            Text("Recordatorio")
                                .font(GCTypography.bodyLarge)
                                .foregroundStyle(.white)
                        }
                    }
                    .tint(Color(hex: "4A90D9"))
                }

                // Reminder time selector
                if enableReminder {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recordar antes")
                            .font(GCTypography.labelMedium)
                            .foregroundStyle(.white.opacity(0.8))

                        HStack(spacing: 8) {
                            ForEach(reminderOptions, id: \.self) { minutes in
                                ReminderChip(
                                    minutes: minutes,
                                    isSelected: reminderMinutes == minutes
                                ) {
                                    reminderMinutes = minutes
                                    GCHaptic.selection.trigger()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Step 3: Details

    private var detailsStep: some View {
        ScrollView {
            VStack(spacing: GentleCareTheme.Spacing.lg) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "AF52DE"))

                    Text("Detalles adicionales")
                        .font(GCTypography.headline2)
                        .foregroundStyle(.white)

                    Text("Informacion opcional")
                        .font(GCTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, GentleCareTheme.Spacing.xl)

                // Preparation instructions
                GlassTextField(
                    "Preparacion",
                    placeholder: "Ej: Ayuno de 8 horas, traer examenes anteriores",
                    text: $preparationInstructions,
                    icon: "list.clipboard.fill",
                    isMultiline: true
                )

                // Notes
                GlassTextField(
                    "Notas",
                    placeholder: "Notas adicionales...",
                    text: $notes,
                    icon: "note.text",
                    isMultiline: true
                )

                // Summary
                GlassCard(size: .large) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen de la cita")
                            .font(GCTypography.titleMedium)
                            .foregroundStyle(.white)

                        Divider()
                            .background(Color.white.opacity(0.2))

                        SummaryRow(icon: "person.fill", label: "Doctor", value: doctorName.isEmpty ? "-" : doctorName)
                        SummaryRow(icon: "stethoscope", label: "Especialidad", value: specialty.rawValue)
                        SummaryRow(icon: "mappin", label: "Ubicacion", value: location.isEmpty ? "-" : location)
                        SummaryRow(icon: "calendar", label: "Fecha", value: formattedDate)
                        SummaryRow(icon: "clock", label: "Hora", value: formattedTime)

                        if enableReminder {
                            SummaryRow(icon: "bell.fill", label: "Recordatorio", value: reminderText)
                        }
                    }
                }

                Spacer(minLength: 80)
            }
            .padding()
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                GlassButton(
                    "Atras",
                    icon: "chevron.left",
                    style: .secondary
                ) {
                    withAnimation {
                        currentStep -= 1
                    }
                }
            }

            if currentStep < 2 {
                GlassButton(
                    "Siguiente",
                    icon: "chevron.right",
                    style: .primary,
                    isDisabled: !canProceed
                ) {
                    withAnimation {
                        currentStep += 1
                    }
                }
            } else {
                GlassButton(
                    "Guardar cita",
                    icon: "checkmark",
                    style: .primary,
                    isDisabled: !canSave
                ) {
                    saveAppointment()
                }
            }
        }
        .padding()
        .background(Color(hex: "1C1C1E"))
    }

    // MARK: - Computed Properties

    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !doctorName.isEmpty && !location.isEmpty
        case 1:
            return true
        default:
            return true
        }
    }

    private var canSave: Bool {
        !doctorName.isEmpty && !location.isEmpty
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d 'de' MMMM, yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: dateTime)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: dateTime)
    }

    private var reminderText: String {
        switch reminderMinutes {
        case 15: return "15 minutos antes"
        case 30: return "30 minutos antes"
        case 60: return "1 hora antes"
        case 120: return "2 horas antes"
        case 1440: return "1 dia antes"
        default: return "\(reminderMinutes) minutos antes"
        }
    }

    // MARK: - Actions

    private func saveAppointment() {
        let appointment = MedicalAppointment(
            doctorName: doctorName,
            specialty: specialty,
            location: location,
            dateTime: dateTime,
            notes: notes.isEmpty ? nil : notes,
            preparationInstructions: preparationInstructions.isEmpty ? nil : preparationInstructions,
            profile: profiles.first
        )

        if enableReminder {
            appointment.reminderMinutesBefore = reminderMinutes
        }

        modelContext.insert(appointment)

        do {
            try modelContext.save()
            GCHaptic.success.trigger()
            dismiss()
        } catch {
            GCHaptic.error.trigger()
        }
    }
}

// MARK: - Specialty Chip

struct SpecialtyChip: View {
    let specialty: MedicalSpecialty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: specialty.icon)
                    .font(.system(size: 16))

                Text(specialty.rawValue)
                    .font(GCTypography.labelSmall)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? specialtyColor : Color.white.opacity(0.1))
            }
        }
    }

    private var specialtyColor: Color {
        switch specialty {
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
}

// MARK: - Reminder Chip

struct ReminderChip: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(GCTypography.labelSmall)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? Color(hex: "FF9500") : Color.white.opacity(0.1))
                }
        }
    }

    private var label: String {
        switch minutes {
        case 15: return "15 min"
        case 30: return "30 min"
        case 60: return "1 hora"
        case 120: return "2 horas"
        case 1440: return "1 dia"
        default: return "\(minutes) min"
        }
    }
}

// MARK: - Summary Row

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "4A90D9"))
                .frame(width: 24)

            Text(label)
                .font(GCTypography.bodyMedium)
                .foregroundStyle(.white.opacity(0.6))

            Spacer()

            Text(value)
                .font(GCTypography.bodyMedium)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    AddAppointmentView()
        .modelContainer(try! ModelContainer.createPreview())
}
