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

    private let lineWidth: CGFloat = 8
    private let size: CGFloat = 120

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)

                if showFlash {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .scaleEffect(showFlash ? 1.2 : 0.8)
                        .animation(.easeOut(duration: 0.4), value: showFlash)

                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                        .scaleEffect(showFlash ? 1.3 : 1.0)
                        .opacity(showFlash ? 0.8 : 0)
                        .animation(.easeOut(duration: 0.6), value: showFlash)
                }

                VStack(spacing: 4) {
                    if showFlash {
                        Text("ROTATE!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    } else if isAwaitingDriver {
                        Text("ROTATE")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.green)
                        Text("AWAITING")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(remainingText)
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))

                        if isOnBreak {
                            Text("BREAK")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showFlash)
            }
            .frame(width: size, height: size)

            if !isOnBreak {
                VStack(spacing: 4) {
                    if let driver = driverName {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("Driver: \(driver)")
                                .font(.callout)
                        }
                    }

                    if let navigator = navigatorName {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                            Text("Navigator: \(navigator)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let rotations = rotationsUntilBreak, rotations > 0 {
                Text("Rotation \(rotations) until break")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var progressColor: Color {
        if isAwaitingDriver {
            return .green
        } else if isOnBreak {
            return .orange
        } else if progress > 0.9 {
            return .red
        } else if progress > 0.7 {
            return .yellow
        } else {
            return .accentColor
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
        rotationsUntilBreak: 3
    )
    .padding()
}
