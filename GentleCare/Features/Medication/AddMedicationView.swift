//
//  AddMedicationView.swift
//  GentleCare
//
//  Multi-step wizard for adding new medications
//

import SwiftUI
import SwiftData

struct AddMedicationView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ElderlyProfile]

    // MARK: - State

    @State private var currentStep = 0
    @State private var name = ""
    @State private var genericName = ""
    @State private var dosage = ""
    @State private var dosageUnit: DosageUnit = .mg
    @State private var frequency: MedicationFrequency = .onceDaily
    @State private var scheduledTimes: [Date] = [createDefaultTime(hour: 8)]
    @State private var color: MedicationColor = .white
    @State private var shape: MedicationShape = .round
    @State private var instructions = ""
    @State private var currentStock: Double = 30

    private let totalSteps = 4

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress
                    progressIndicator
                        .padding(.top, GentleCareTheme.Spacing.md)

                    // Content
                    TabView(selection: $currentStep) {
                        basicInfoStep.tag(0)
                        scheduleStep.tag(1)
                        appearanceStep.tag(2)
                        reviewStep.tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Navigation
                    navigationButtons
                        .padding(.horizontal)
                        .padding(.bottom, GentleCareTheme.Spacing.lg)
                }
            }
            .navigationTitle("Nuevo medicamento")
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

    // MARK: - Progress

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(step <= currentStep ? Color(hex: "4A90D9") : Color.white.opacity(0.2))
                        .frame(height: 4)

                    Text(stepTitle(step))
                        .font(GCTypography.captionSmall)
                        .foregroundStyle(step <= currentStep ? .white : .white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal)
    }

    private func stepTitle(_ step: Int) -> String {
        switch step {
        case 0: return "Info"
        case 1: return "Horario"
        case 2: return "Aspecto"
        case 3: return "Revisar"
        default: return ""
        }
    }

    // MARK: - Step 1: Basic Info

    private var basicInfoStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                Text("Informacion basica")
                    .font(GCTypography.headline2)
                    .foregroundStyle(.white)
                    .padding(.top)

                GlassTextField(
                    "Nombre del medicamento",
                    placeholder: "Ej: Lisinopril",
                    text: $name,
                    icon: "pills.fill"
                )

                GlassTextField(
                    "Nombre generico (opcional)",
                    placeholder: "Ej: Lisinopril",
                    text: $genericName,
                    icon: "doc.text"
                )

                HStack(spacing: 12) {
                    GlassTextField(
                        "Dosis",
                        placeholder: "10",
                        text: $dosage,
                        icon: "number",
                        keyboardType: .decimalPad
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unidad")
                            .font(GCTypography.labelMedium)
                            .foregroundStyle(.white.opacity(0.8))

                        Picker("Unidad", selection: $dosageUnit) {
                            ForEach(DosageUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        .padding()
                        .frame(height: 60)
                        .glassEffect(style: .subtle, cornerRadius: GentleCareTheme.CornerRadius.md)
                    }
                }

                GlassTextField(
                    "Instrucciones (opcional)",
                    placeholder: "Ej: Tomar con alimentos",
                    text: $instructions,
                    icon: "text.alignleft",
                    isMultiline: true
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Step 2: Schedule

    private var scheduleStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                Text("Horario")
                    .font(GCTypography.headline2)
                    .foregroundStyle(.white)
                    .padding(.top)

                // Frequency
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frecuencia")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(MedicationFrequency.allCases) { freq in
                            FrequencyChip(
                                frequency: freq,
                                isSelected: frequency == freq
                            ) {
                                frequency = freq
                                updateScheduledTimes()
                                GCHaptic.selection.trigger()
                            }
                        }
                    }
                }

                // Times
                VStack(alignment: .leading, spacing: 12) {
                    Text("Horarios")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    ForEach(scheduledTimes.indices, id: \.self) { index in
                        HStack {
                            DatePicker(
                                "",
                                selection: $scheduledTimes[index],
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(Color(hex: "4A90D9"))

                            Spacer()

                            if scheduledTimes.count > 1 {
                                Button {
                                    scheduledTimes.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(hex: "FF6B6B"))
                                }
                            }
                        }
                        .padding()
                        .glassEffect(style: .subtle, cornerRadius: GentleCareTheme.CornerRadius.md)
                    }

                    if frequency == .custom {
                        Button {
                            scheduledTimes.append(createDefaultTime(hour: 12))
                        } label: {
                            Label("Agregar horario", systemImage: "plus.circle.fill")
                                .font(GCTypography.labelMedium)
                                .foregroundStyle(Color(hex: "4A90D9"))
                        }
                    }
                }

                // Stock
                GlassNumericInput(
                    "Stock actual",
                    value: $currentStock,
                    range: 1...500,
                    step: 1,
                    unit: "unidades",
                    icon: "shippingbox.fill"
                )
            }
            .padding(.horizontal)
        }
    }

    private func updateScheduledTimes() {
        let times = frequency.timesPerDay
        if times > 0 {
            scheduledTimes = (0..<times).map { index in
                createDefaultTime(hour: 8 + (index * (24 / times)))
            }
        }
    }

    // MARK: - Step 3: Appearance

    private var appearanceStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                Text("Apariencia")
                    .font(GCTypography.headline2)
                    .foregroundStyle(.white)
                    .padding(.top)

                Text("Ayuda a identificar el medicamento visualmente")
                    .font(GCTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.6))

                // Color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(MedicationColor.allCases) { c in
                            ColorChip(color: c, isSelected: color == c) {
                                color = c
                                GCHaptic.selection.trigger()
                            }
                        }
                    }
                }

                // Shape
                VStack(alignment: .leading, spacing: 12) {
                    Text("Forma")
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(MedicationShape.allCases) { s in
                            ShapeChip(shape: s, isSelected: shape == s) {
                                shape = s
                                GCHaptic.selection.trigger()
                            }
                        }
                    }
                }

                // Preview
                GlassCard(size: .medium) {
                    HStack {
                        Text("Vista previa")
                            .font(GCTypography.labelMedium)
                            .foregroundStyle(.white.opacity(0.6))

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedColor.opacity(0.3))
                                .frame(width: 60, height: 60)

                            Image(systemName: shape.icon)
                                .font(.system(size: 30))
                                .foregroundStyle(selectedColor)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var selectedColor: Color {
        switch color {
        case .white: return .white
        case .blue: return .blue
        case .pink: return .pink
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        case .green: return .green
        case .purple: return .purple
        case .brown: return .brown
        case .beige: return Color(hex: "F5DEB3")
        }
    }

    // MARK: - Step 4: Review

    private var reviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.lg) {
                Text("Revisar")
                    .font(GCTypography.headline2)
                    .foregroundStyle(.white)
                    .padding(.top)

                GlassCard(size: .large) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedColor.opacity(0.3))
                                    .frame(width: 60, height: 60)

                                Image(systemName: shape.icon)
                                    .font(.system(size: 30))
                                    .foregroundStyle(selectedColor)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(name.isEmpty ? "Sin nombre" : name)
                                    .font(GCTypography.headline2)
                                    .foregroundStyle(.white)

                                Text("\(dosage.isEmpty ? "0" : dosage) \(dosageUnit.rawValue)")
                                    .font(GCTypography.bodyLarge)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        DetailRow(label: "Frecuencia", value: frequency.rawValue)
                        DetailRow(label: "Horarios", value: formattedTimes)
                        DetailRow(label: "Stock inicial", value: "\(Int(currentStock)) unidades")

                        if !instructions.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Instrucciones")
                                    .font(GCTypography.labelMedium)
                                    .foregroundStyle(.white.opacity(0.6))
                                Text(instructions)
                                    .font(GCTypography.bodyMedium)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var formattedTimes: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return scheduledTimes.map { formatter.string(from: $0) }.joined(separator: ", ")
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                GlassButton("Atras", style: .secondary, isFullWidth: false) {
                    withAnimation { currentStep -= 1 }
                }
            }

            GlassButton(
                currentStep == totalSteps - 1 ? "Guardar" : "Siguiente",
                icon: currentStep == totalSteps - 1 ? "checkmark" : nil,
                style: .primary,
                isDisabled: !canProceed
            ) {
                if currentStep == totalSteps - 1 {
                    saveMedication()
                } else {
                    withAnimation { currentStep += 1 }
                }
            }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !name.isEmpty && !dosage.isEmpty
        default:
            return true
        }
    }

    // MARK: - Save

    private func saveMedication() {
        let medication = Medication(
            name: name,
            genericName: genericName.isEmpty ? nil : genericName,
            dosage: dosage,
            dosageUnit: dosageUnit,
            frequency: frequency,
            scheduledTimes: scheduledTimes,
            color: color,
            shape: shape,
            profile: profiles.first
        )

        medication.instructions = instructions.isEmpty ? nil : instructions
        medication.currentStock = Int(currentStock)

        modelContext.insert(medication)

        do {
            try modelContext.save()
            GCHaptic.success.trigger()
            dismiss()
        } catch {
            GCHaptic.error.trigger()
        }
    }

}

private func createDefaultTime(hour: Int) -> Date {
    var components = DateComponents()
    components.hour = hour
    components.minute = 0
    return Calendar.current.date(from: components) ?? Date()
}

// MARK: - Frequency Chip

struct FrequencyChip: View {
    let frequency: MedicationFrequency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(frequency.rawValue)
                .font(GCTypography.labelMedium)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(hex: "4A90D9") : Color.white.opacity(0.1))
                }
        }
    }
}

// MARK: - Color Chip

struct ColorChip: View {
    let color: MedicationColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(colorValue)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Circle()
                        .stroke(Color(hex: "4A90D9"), lineWidth: 3)
                        .frame(width: 52, height: 52)
                }
            }
        }
    }

    private var colorValue: Color {
        switch color {
        case .white: return .white
        case .blue: return .blue
        case .pink: return .pink
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        case .green: return .green
        case .purple: return .purple
        case .brown: return .brown
        case .beige: return Color(hex: "F5DEB3")
        }
    }
}

// MARK: - Shape Chip

struct ShapeChip: View {
    let shape: MedicationShape
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: shape.icon)
                    .font(.system(size: 24))

                Text(shape.rawValue)
                    .font(GCTypography.captionSmall)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "4A90D9") : Color.white.opacity(0.1))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddMedicationView()
        .modelContainer(try! ModelContainer.createPreview())
}
