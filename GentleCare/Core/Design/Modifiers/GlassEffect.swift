//
//  GlassEffect.swift
//  GentleCare
//
//  iOS 26 Liquid Glass effect modifier
//

import SwiftUI

// MARK: - Glass Effect Modifier

struct GlassEffectModifier: ViewModifier {

    enum Style {
        case regular    // For controls and navigation
        case clear      // For content over rich backgrounds
        case subtle     // Light glass effect
        case prominent  // Strong glass effect
    }

    let style: Style
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                glassBackground
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                glassOverlay
            }
    }

    @ViewBuilder
    private var glassBackground: some View {
        switch style {
        case .regular:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)

        case .clear:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial.opacity(0.5))

        case .subtle:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial.opacity(0.3))

        case .prominent:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.regularMaterial)
        }
    }

    private var glassOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(borderOpacity),
                        Color.white.opacity(borderOpacity * 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private var borderOpacity: Double {
        switch style {
        case .regular: return 0.2
        case .clear: return 0.15
        case .subtle: return 0.1
        case .prominent: return 0.3
        }
    }
}

// MARK: - View Extension

extension View {

    /// Apply Liquid Glass effect with customizable style
    func glassEffect(
        style: GlassEffectModifier.Style = .regular,
        cornerRadius: CGFloat = GentleCareTheme.CornerRadius.lg
    ) -> some View {
        modifier(GlassEffectModifier(style: style, cornerRadius: cornerRadius))
    }

    /// Quick glass card effect
    func glassCard(cornerRadius: CGFloat = GentleCareTheme.CornerRadius.lg) -> some View {
        glassEffect(style: .regular, cornerRadius: cornerRadius)
    }

    /// Subtle glass for overlays
    func subtleGlass(cornerRadius: CGFloat = GentleCareTheme.CornerRadius.md) -> some View {
        glassEffect(style: .subtle, cornerRadius: cornerRadius)
    }
}

// MARK: - Glass Container

struct GlassContainer<Content: View>: View {

    let style: GlassEffectModifier.Style
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        style: GlassEffectModifier.Style = .regular,
        cornerRadius: CGFloat = GentleCareTheme.CornerRadius.lg,
        padding: CGFloat = GentleCareTheme.Spacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .glassEffect(style: style, cornerRadius: cornerRadius)
    }
}

// MARK: - Preview

#Preview("GlassEffect Styles") {
    ZStack {
        // Background gradient
        LinearGradient(
            colors: [Color(hex: "1C1C1E"), Color(hex: "2C2C2E")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 20) {
            Text("Regular Glass")
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(style: .regular)

            Text("Clear Glass")
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(style: .clear)

            Text("Subtle Glass")
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(style: .subtle)

            Text("Prominent Glass")
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(style: .prominent)

            GlassContainer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Glass Container")
                        .font(.headline)
                    Text("With automatic padding and styling")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.white)
        }
        .padding()
    }
}
