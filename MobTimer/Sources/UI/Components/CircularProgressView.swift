import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let remainingText: String
    let driverName: String?
    let navigatorName: String?
    let isOnBreak: Bool
    let isAwaitingDriver: Bool
    let rotationsUntilBreak: Int?
    var showFlash: Bool = false
    var theme: AppTheme = .mint

    private let lineWidth: CGFloat = 12
    private let size: CGFloat = 140

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.secondary.opacity(0.1), lineWidth: lineWidth)

                // Progress Fill
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressGradient,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: progressColor.opacity(0.3), radius: 5)
                    .animation(.linear(duration: 0.3), value: progress)

                // Flash Effects
                if showFlash {
                    Circle()
                        .fill(Theme.Colors.primary(for: theme).opacity(0.3))
                        .scaleEffect(showFlash ? 1.2 : 0.8)
                        .animation(.easeOut(duration: 0.4), value: showFlash)

                    Circle()
                        .stroke(Theme.Colors.primary(for: theme), lineWidth: 3)
                        .scaleEffect(showFlash ? 1.3 : 1.0)
                        .opacity(showFlash ? 0.8 : 0)
                        .animation(.easeOut(duration: 0.6), value: showFlash)
                }

                // Center Text
                VStack(spacing: 4) {
                    if showFlash {
                        Text("ROTATE!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.primary(for: theme))
                            .transition(.scale.combined(with: .opacity))
                    } else if isAwaitingDriver {
                        Text("ROTATE")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.Colors.primary(for: theme))
                        Text("AWAITING")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(remainingText)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .contentTransition(.numericText(value: 0))

                        if isOnBreak {
                            Text("BREAK")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Theme.Colors.warning(for: theme))
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showFlash)
            }
            .frame(width: size, height: size)

            // Info below circle
            if !isOnBreak {
                VStack(spacing: 6) {
                    if let driver = driverName {
                        HStack(spacing: 6) {
                            Image(systemName: "steeringwheel")
                                .font(.caption)
                                .foregroundStyle(Theme.Colors.primary(for: theme))
                            Text(driver)
                                .font(.callout.weight(.medium))
                        }
                    }

                    if let navigator = navigatorName {
                        HStack(spacing: 6) {
                            Image(systemName: "map")
                                .font(.caption)
                                .foregroundStyle(Theme.Colors.secondary(for: theme))
                            Text(navigator)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Next Break Indicator
            if let rotations = rotationsUntilBreak, rotations > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.caption2)
                    Text("Break in \(rotations)")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Capsule().fill(.quaternary))
            }
        }
    }

    private var progressColor: Color {
        if isAwaitingDriver {
            return Theme.Colors.primary(for: theme)
        } else if isOnBreak {
            return Theme.Colors.warning(for: theme)
        } else if progress > 0.9 {
            return Theme.Colors.destructive
        } else if progress > 0.7 {
            return Theme.Colors.warning(for: theme)
        } else {
            return Theme.Colors.primary(for: theme)
        }
    }
    
    private var progressGradient: AngularGradient {
        if isAwaitingDriver {
            return Theme.Gradients.primaryAngular(for: theme)
        } else if isOnBreak {
            return AngularGradient(gradient: Gradient(colors: [.orange, .yellow, .orange]), center: .center)
        } else if progress > 0.9 {
            return AngularGradient(gradient: Gradient(colors: [.red, .orange, .red]), center: .center)
        } else {
            return Theme.Gradients.primaryAngular(for: theme)
        }
    }
}

#Preview {
    CircularProgressView(
        progress: 0.65,
        remainingText: "04:32",
        driverName: "Alice",
        navigatorName: "Bob",
        isOnBreak: false,
        isAwaitingDriver: false,
        rotationsUntilBreak: 3,
        theme: .mint
    )
    .padding()
}
