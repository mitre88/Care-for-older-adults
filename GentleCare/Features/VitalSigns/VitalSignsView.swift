//
//  VitalSignsView.swift
//  GentleCare
//
//  Vital signs dashboard with gauges and history
//

import SwiftUI
import SwiftData
import Charts

struct VitalSignsView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VitalSign.measuredAt, order: .reverse) private var vitalSigns: [VitalSign]

    // MARK: - State

    @State private var selectedType: VitalSignType?
    @State private var showingAddVital = false

    // MARK: - Computed

    private var latestByType: [VitalSignType: VitalSign] {
        var latest: [VitalSignType: VitalSign] = [:]
        for vital in vitalSigns {
            if latest[vital.type] == nil {
                latest[vital.type] = vital
            }
        }
        return latest
    }

    private var selectedVitals: [VitalSign] {
        guard let type = selectedType else { return [] }
        return vitalSigns
            .filter { $0.type == type }
            .prefix(30)
            .map { $0 }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(hex: "1C1C1E")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: GentleCareTheme.Spacing.lg) {
                    // Vital gauges grid
                    vitalsGrid

                    // History chart
                    if selectedType != nil && !selectedVitals.isEmpty {
                        historySection
                    }

                    // Recent readings
                    recentReadingsSection
                }
                .padding()
                .padding(.bottom, 80)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "plus") {
                        showingAddVital = true
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Signos Vitales")
        .sheet(isPresented: $showingAddVital) {
            AddVitalReadingView()
        }
    }

    // MARK: - Vitals Grid

    private var vitalsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(VitalSignType.allCases) { type in
                VitalGaugeCard(
                    type: type,
                    vital: latestByType[type],
                    isSelected: selectedType == type
                ) {
                    withAnimation {
                        selectedType = selectedType == type ? nil : type
                    }
                    GCHaptic.selection.trigger()
                }
            }
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Historial - \(selectedType?.rawValue ?? "")")
                    .font(GCTypography.titleMedium)
                    .foregroundStyle(.white)

                Spacer()

                Button("Cerrar") {
                    withAnimation { selectedType = nil }
                }
                .font(GCTypography.labelMedium)
                .foregroundStyle(Color(hex: "4A90D9"))
            }

            GlassCard(size: .large) {
                VStack(alignment: .leading, spacing: 16) {
                    // Chart
                    Chart(selectedVitals.reversed()) { vital in
                        LineMark(
                            x: .value("Fecha", vital.measuredAt),
                            y: .value("Valor", vital.value)
                        )
                        .foregroundStyle(Color(hex: "4A90D9"))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Fecha", vital.measuredAt),
                            y: .value("Valor", vital.value)
                        )
                        .foregroundStyle(statusColor(for: vital))
                    }
                    .chartYScale(domain: (selectedType?.minValue ?? 0)...(selectedType?.maxValue ?? 100))
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            AxisValueLabel(format: .dateTime.day().month())
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel()
                                .foregroundStyle(.white.opacity(0.6))
                            AxisGridLine()
                                .foregroundStyle(.white.opacity(0.1))
                        }
                    }
                    .frame(height: 200)

                    // Stats
                    HStack(spacing: 20) {
                        StatItem(label: "Promedio", value: averageValue)
                        StatItem(label: "Minimo", value: minValue)
                        StatItem(label: "Maximo", value: maxValue)
                    }
                }
            }
        }
    }

    private var averageValue: String {
        guard !selectedVitals.isEmpty else { return "-" }
        let avg = selectedVitals.map(\.value).reduce(0, +) / Double(selectedVitals.count)
        return String(format: "%.0f", avg)
    }

    private var minValue: String {
        guard let min = selectedVitals.map(\.value).min() else { return "-" }
        return String(format: "%.0f", min)
    }

    private var maxValue: String {
        guard let max = selectedVitals.map(\.value).max() else { return "-" }
        return String(format: "%.0f", max)
    }

    private func statusColor(for vital: VitalSign) -> Color {
        switch vital.status {
        case .low: return Color(hex: "5AC8FA")
        case .normal: return Color(hex: "34C759")
        case .high: return Color(hex: "FF6B6B")
        }
    }

    // MARK: - Recent Readings

    private var recentReadingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lecturas recientes")
                .font(GCTypography.titleMedium)
                .foregroundStyle(.white)

            ForEach(vitalSigns.prefix(10), id: \.id) { vital in
                RecentVitalRow(vital: vital)
            }
        }
    }
}

// MARK: - Vital Gauge Card

struct VitalGaugeCard: View {

    let type: VitalSignType
    let vital: VitalSign?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GlassCard(size: .medium, glassStyle: isSelected ? .prominent : .regular) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: type.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(iconColor)

                        Spacer()

                        if let vital {
                            Image(systemName: vital.status.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(statusColor)
                        }
                    }

                    Spacer()

                    if let vital {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(vital.formattedValue)
                                .font(GCTypography.numericSmall)
                                .foregroundStyle(.white)

                            Text(vital.unit)
                                .font(GCTypography.labelSmall)
                                .foregroundStyle(.white.opacity(0.6))
                        }

                        Text(vital.relativeTime)
                            .font(GCTypography.captionSmall)
                            .foregroundStyle(.white.opacity(0.5))
                    } else {
                        Text("Sin datos")
                            .font(GCTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Text(type.rawValue)
                        .font(GCTypography.labelSmall)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
                .frame(height: 120)
            }
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        Color(hex: typeColorHex)
    }

    private var statusColor: Color {
        guard let vital else { return .clear }
        switch vital.status {
        case .low: return Color(hex: "5AC8FA")
        case .normal: return Color(hex: "34C759")
        case .high: return Color(hex: "FF6B6B")
        }
    }

    private var typeColorHex: String {
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

// MARK: - Stat Item

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(GCTypography.titleLarge)
                .foregroundStyle(.white)

            Text(label)
                .font(GCTypography.captionMedium)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Recent Vital Row

struct RecentVitalRow: View {
    let vital: VitalSign

    var body: some View {
        GlassCard(size: .small) {
            HStack {
                Image(systemName: vital.type.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(typeColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(vital.type.rawValue)
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white)

                    Text(vital.formattedDate)
                        .font(GCTypography.captionSmall)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(vital.formattedWithUnit)
                        .font(GCTypography.titleSmall)
                        .foregroundStyle(.white)

                    Text(vital.status.rawValue)
                        .font(GCTypography.captionSmall)
                        .foregroundStyle(statusColor)
                }
            }
        }
    }

    private var typeColor: Color {
        switch vital.type {
        case .bloodPressure: return Color(hex: "FF6B6B")
        case .heartRate: return Color(hex: "FF2D55")
        case .bloodOxygen: return Color(hex: "5AC8FA")
        case .temperature: return Color(hex: "FF9500")
        case .bloodGlucose: return Color(hex: "AF52DE")
        case .weight: return Color(hex: "30D158")
        case .respiratoryRate: return Color(hex: "64D2FF")
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

// MARK: - Preview

#Preview {
    NavigationStack {
        VitalSignsView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(try! ModelContainer.createPreview())
}
