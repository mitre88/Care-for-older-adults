//
//  AddVitalReadingView.swift
//  GentleCare
//
//  View for recording new vital sign readings
//

import SwiftUI
import SwiftData

struct AddVitalReadingView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ElderlyProfile]

    // MARK: - Properties

    var preselectedType: VitalSignType?

    // MARK: - State

    @State private var selectedType: VitalSignType = .bloodPressure
    @State private var value: Double = 120
    @State private var secondaryValue: Double = 80
    @State private var notes = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1C1C1E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: GentleCareTheme.Spacing.lg) {
                        // Type selector
                        if preselectedType == nil {
                            typeSelector
                        }

                        // Value input
                        valueInput

                        // Notes
                        GlassTextField(
                            "Notas (opcional)",
                            placeholder: "Agregar notas...",
                            text: $notes,
                            icon: "note.text",
                            isMultiline: true
                        )

                        // Status preview
                        statusPreview

                        Spacer(minLength: 100)
                    }
                    .padding()
                }

                // Save button
                VStack {
                    Spacer()

                    GlassButton(
                        "Guardar lectura",
                        icon: "checkmark",
                        style: .primary,
                        size: .extraLarge
                    ) {
                        saveReading()
                    }
                    .padding()
                    .background {
                        LinearGradient(
                            colors: [Color(hex: "1C1C1E").opacity(0), Color(hex: "1C1C1E")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }
                }
            }
            .navigationTitle("Nueva lectura")
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
                if let type = preselectedType {
                    selectedType = type
                }
                updateDefaultValues()
            }
        }
    }

    // MARK: - Type Selector

    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de lectura")
                .font(GCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.8))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(VitalSignType.allCases) { type in
                        VitalTypeChip(
                            type: type,
                            isSelected: selectedType == type
                        ) {
                            selectedType = type
                            updateDefaultValues()
                            GCHaptic.selection.trigger()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Value Input

    private var valueInput: some View {
        VStack(spacing: GentleCareTheme.Spacing.lg) {
            // Main value
            GlassNumericInput(
                selectedType.requiresSecondaryValue ? "Sistolica" : selectedType.rawValue,
                value: $value,
                range: selectedType.minValue...selectedType.maxValue,
                step: stepForType,
                unit: selectedType.defaultUnit,
                icon: selectedType.icon
            )

            // Secondary value (for blood pressure)
            if selectedType.requiresSecondaryValue {
                GlassNumericInput(
                    "Diastolica",
                    value: $secondaryValue,
                    range: 40...140,
                    step: 1,
                    unit: "mmHg",
                    icon: "arrow.down.heart"
                )
            }
        }
    }

    private var stepForType: Double {
        switch selectedType {
        case .temperature: return 0.1
        case .weight: return 0.5
        default: return 1
        }
    }

    // MARK: - Status Preview

    private var statusPreview: some View {
        let status = calculateStatus()

        return GlassCard(size: .medium) {
            HStack {
                Image(systemName: status.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(statusColor(for: status))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado: \(status.rawValue)")
                        .font(GCTypography.titleMedium)
                        .foregroundStyle(.white)

                    Text(statusMessage(for: status))
                        .font(GCTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }
        }
    }

    private func calculateStatus() -> VitalStatus {
        let range = selectedType.normalRange
        if value < range.lowerBound {
            return .low
        } else if value > range.upperBound {
            return .high
        }
        return .normal
    }

    private func statusColor(for status: VitalStatus) -> Color {
        switch status {
        case .low: return Color(hex: "5AC8FA")
        case .normal: return Color(hex: "34C759")
        case .high: return Color(hex: "FF6B6B")
        }
    }

    private func statusMessage(for status: VitalStatus) -> String {
        switch status {
        case .low: return "El valor esta por debajo del rango normal"
        case .normal: return "El valor esta dentro del rango normal"
        case .high: return "El valor esta por encima del rango normal"
        }
    }

    // MARK: - Actions

    private func updateDefaultValues() {
        switch selectedType {
        case .bloodPressure:
            value = 120
            secondaryValue = 80
        case .heartRate:
            value = 72
        case .bloodOxygen:
            value = 98
        case .temperature:
            value = 36.5
        case .bloodGlucose:
            value = 100
        case .weight:
            value = 70
        case .respiratoryRate:
            value = 16
        }
    }

    private func saveReading() {
        let vital = VitalSign(
            type: selectedType,
            value: value,
            secondaryValue: selectedType.requiresSecondaryValue ? secondaryValue : nil,
            notes: notes.isEmpty ? nil : notes,
            profile: profiles.first
        )

        modelContext.insert(vital)

        do {
            try modelContext.save()
            GCHaptic.success.trigger()
            dismiss()
        } catch {
            GCHaptic.error.trigger()
        }
    }
}

// MARK: - Vital Type Chip

struct VitalTypeChip: View {
    let type: VitalSignType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))

                Text(shortName)
                    .font(GCTypography.captionSmall)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .frame(width: 70, height: 70)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: typeColor) : Color.white.opacity(0.1))
            }
        }
    }

    private var shortName: String {
        switch type {
        case .bloodPressure: return "Presion"
        case .heartRate: return "Pulso"
        case .bloodOxygen: return "Oxigeno"
        case .temperature: return "Temp"
        case .bloodGlucose: return "Glucosa"
        case .weight: return "Peso"
        case .respiratoryRate: return "Resp"
        }
    }

    private var typeColor: String {
        switch type {
        case .bloodPressure: return "FF6B6B"
        case .heartRate: return "FF2D55"
        case .bloodOxygen: return "5AC8FA"
        case .temperature: return "FF9500"
        case .bloodGlucose: return "AF52DE"
        case .weight: return "30D158"
        case .respiratoryRate: return "64D2FF"
        }
    }
}

// MARK: - Preview

#Preview {
    AddVitalReadingView()
        .modelContainer(try! ModelContainer.createPreview())
}
