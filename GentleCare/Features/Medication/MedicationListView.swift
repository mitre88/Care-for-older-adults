//
//  MedicationListView.swift
//  GentleCare
//
//  Medication list and management view
//

import SwiftUI
import SwiftData

struct MedicationListView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Medication.name) private var medications: [Medication]

    // MARK: - State

    @State private var searchText = ""
    @State private var selectedFilter: MedicationFilter = .all
    @State private var showingAddMedication = false
    @State private var selectedMedication: Medication?

    // MARK: - Filters

    enum MedicationFilter: String, CaseIterable, Identifiable {
        case all = "Todos"
        case active = "Activos"
        case needsRefill = "Recarga"

        var id: String { rawValue }
    }

    // MARK: - Filtered Medications

    private var filteredMedications: [Medication] {
        var result = medications

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .active:
            result = result.filter { $0.isActive }
        case .needsRefill:
            result = result.filter { $0.needsRefill }
        }

        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.genericName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(hex: "1C1C1E")
                .ignoresSafeArea()

            if medications.isEmpty {
                emptyState
            } else {
                medicationsList
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "plus") {
                        showingAddMedication = true
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Medicamentos")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Buscar medicamento")
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView()
        }
        .sheet(item: $selectedMedication) { medication in
            MedicationDetailSheet(medication: medication)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: GentleCareTheme.Spacing.lg) {
            Image(systemName: "pills")
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "4A90D9").opacity(0.5))

            VStack(spacing: 8) {
                Text("Sin medicamentos")
                    .font(GCTypography.headline2)
                    .foregroundStyle(.white)

                Text("Agrega el primer medicamento\npara comenzar el seguimiento")
                    .font(GCTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            GlassButton(
                "Agregar medicamento",
                icon: "plus",
                style: .primary,
                size: .large,
                isFullWidth: false
            ) {
                showingAddMedication = true
            }
        }
        .padding()
    }

    // MARK: - Medications List

    private var medicationsList: some View {
        ScrollView {
            VStack(spacing: GentleCareTheme.Spacing.md) {
                // Filter chips
                filterChips
                    .padding(.horizontal)

                // Medications
                LazyVStack(spacing: 12) {
                    ForEach(filteredMedications, id: \.id) { medication in
                        MedicationCard(medication: medication) {
                            selectedMedication = medication
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Space for FAB
            }
            .padding(.top)
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MedicationFilter.allCases) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        count: countForFilter(filter)
                    ) {
                        selectedFilter = filter
                        GCHaptic.selection.trigger()
                    }
                }
            }
        }
    }

    private func countForFilter(_ filter: MedicationFilter) -> Int {
        switch filter {
        case .all: return medications.count
        case .active: return medications.filter { $0.isActive }.count
        case .needsRefill: return medications.filter { $0.needsRefill }.count
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
                        .font(GCTypography.captionMedium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background {
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        }
                }
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(isSelected ? Color(hex: "4A90D9") : Color.white.opacity(0.1))
            }
        }
    }
}

// MARK: - Medication Card

struct MedicationCard: View {

    let medication: Medication
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GlassCard(size: .medium, isInteractive: true) {
                HStack(spacing: 16) {
                    // Medication icon/color
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(medicationColor.opacity(0.3))
                            .frame(width: 56, height: 56)

                        Image(systemName: medication.shape.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(medicationColor)
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(medication.name)
                            .font(GCTypography.titleMedium)
                            .foregroundStyle(.white)

                        Text(medication.formattedDosage)
                            .font(GCTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.7))

                        HStack(spacing: 8) {
                            Label(medication.frequency.rawValue, systemImage: "clock")
                                .font(GCTypography.captionMedium)
                                .foregroundStyle(.white.opacity(0.5))

                            if medication.needsRefill {
                                Label("Recarga", systemImage: "exclamationmark.triangle.fill")
                                    .font(GCTypography.captionMedium)
                                    .foregroundStyle(Color(hex: "FFB340"))
                            }
                        }
                    }

                    Spacer()

                    // Next dose
                    if let nextTime = medication.timeUntilNextDose {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(nextTime)
                                .font(GCTypography.labelMedium)
                                .foregroundStyle(Color(hex: "4A90D9"))

                            Text("proxima")
                                .font(GCTypography.captionSmall)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var medicationColor: Color {
        switch medication.color {
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

// MARK: - Medication Detail Sheet

struct MedicationDetailSheet: View {

    @Environment(\.dismiss) private var dismiss
    let medication: Medication

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: GentleCareTheme.Spacing.lg) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "4A90D9").opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: "pills.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color(hex: "4A90D9"))
                        }

                        Text(medication.name)
                            .font(GCTypography.headline1)
                            .foregroundStyle(.white)

                        Text(medication.formattedDosage)
                            .font(GCTypography.bodyLarge)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top)

                    // Quick actions
                    HStack(spacing: 16) {
                        GlassButton(
                            "Tomar ahora",
                            icon: "checkmark",
                            style: .success,
                            size: .large
                        ) {
                            // Mark as taken
                            GCHaptic.success.trigger()
                            dismiss()
                        }
                    }
                    .padding(.horizontal)

                    // Details
                    GlassCard(size: .large) {
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(label: "Frecuencia", value: medication.frequency.rawValue)
                            DetailRow(label: "Stock actual", value: "\(medication.currentStock) unidades")

                            if medication.needsRefill {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(Color(hex: "FFB340"))
                                    Text("Necesita recarga pronto")
                                        .foregroundStyle(Color(hex: "FFB340"))
                                }
                                .font(GCTypography.labelMedium)
                            }

                            if let instructions = medication.instructions {
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
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color(hex: "1C1C1E"))
            .navigationTitle("Detalle")
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(GCTypography.labelMedium)
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
    NavigationStack {
        MedicationListView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(try! ModelContainer.createPreview())
}
