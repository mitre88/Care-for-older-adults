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

    @State private var title = ""
    @State private var doctorName = ""
    @State private var specialty: MedicalSpecialty = .generalPractitioner
    @State private var location = ""
    @State private var appointmentDate = Date().addingTimeInterval(86400)
    @State private var notes = ""
    @State private var preparationInstructions = ""

    @State private var currentStep = 0

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

                // Title
                GlassTextField(
                    "Titulo de la cita",
                    placeholder: "Ej: Control anual",
                    text: $title,
                    icon: "calendar"
                )

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
                        ForEach(MedicalSpecialty.allCases.prefix(10), id: \.self) { spec in
                            AppointmentSpecialtyChip(
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
                        selection: $appointmentDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color(hex: "4A90D9"))
                    .colorScheme(.dark)
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

                        AppointmentSummaryRow(icon: "calendar", label: "Titulo", value: title.isEmpty ? "-" : title)
                        AppointmentSummaryRow(icon: "person.fill", label: "Doctor", value: doctorName.isEmpty ? "-" : doctorName)
                        AppointmentSummaryRow(icon: "stethoscope", label: "Especialidad", value: specialty.rawValue)
                        AppointmentSummaryRow(icon: "mappin", label: "Ubicacion", value: location.isEmpty ? "-" : location)
                        AppointmentSummaryRow(icon: "calendar", label: "Fecha", value: formattedDate)
                        AppointmentSummaryRow(icon: "clock", label: "Hora", value: formattedTime)
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
        return formatter.string(from: appointmentDate)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: appointmentDate)
    }

    // MARK: - Actions

    private func saveAppointment() {
        let appointment = MedicalAppointment(
            title: title.isEmpty ? specialty.rawValue : title,
            doctorName: doctorName,
            specialty: specialty,
            location: location,
            appointmentDate: appointmentDate,
            profile: profiles.first
        )

        if !notes.isEmpty {
            appointment.notes = notes
        }
        if !preparationInstructions.isEmpty {
            appointment.preparationInstructions = preparationInstructions
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

// MARK: - Appointment Specialty Chip

struct AppointmentSpecialtyChip: View {
    let specialty: MedicalSpecialty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: specialty.icon)
                    .font(.system(size: 16))

                Text(shortName)
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

    private var shortName: String {
        switch specialty {
        case .generalPractitioner: return "General"
        case .cardiologist: return "Cardio"
        case .neurologist: return "Neuro"
        case .orthopedist: return "Trauma"
        case .dermatologist: return "Dermato"
        case .ophthalmologist: return "Oftalmo"
        case .geriatrician: return "Geriatria"
        case .psychiatrist: return "Psiquiat"
        case .endocrinologist: return "Endocri"
        default: return "Otro"
        }
    }

    private var specialtyColor: Color {
        switch specialty {
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
}

// MARK: - Appointment Summary Row

struct AppointmentSummaryRow: View {
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

#Preview("Add Appointment") {
    AddAppointmentView()
        .modelContainer(try! ModelContainer.createPreview())
}
