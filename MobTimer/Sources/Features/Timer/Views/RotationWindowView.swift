import SwiftUI

struct RotationWindowView: View {
    @Bindable var viewModel: TimerViewModel
    @State private var isAnimating = false
    @State private var pulseReady = false
    @State private var showContent = false

    private let encouragements = [
        "Let's go! 🚀",
        "Time to shine! ✨",
        "You've got this! 💪",
        "Fresh perspective! 🎯",
        "Your turn to lead! 🌟"
    ]

    @State private var currentEncouragement: String = ""

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.green.opacity(0.15),
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05)
                ],
                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                endPoint: isAnimating ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)

            VStack(spacing: 28) {
                // Animated header
                VStack(spacing: 12) {
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.green, .mint, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: isAnimating)
                            .opacity(0.6)

                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                    }

                    Text("ROTATE!")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text(currentEncouragement)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)

                // Driver/Navigator card
                VStack(spacing: 16) {
                    if let driver = viewModel.currentDriver {
                        VStack(spacing: 8) {
                            Text(driver.name)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text("you're driving!")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()
                        .padding(.horizontal, 40)

                    HStack(spacing: 32) {
                        if let navigator = viewModel.currentNavigator {
                            VStack(spacing: 4) {
                                Image(systemName: "map.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text(navigator.name)
                                    .font(.headline)
                                Text("Navigator")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let nextUp = viewModel.nextDriver {
                            VStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                Text(nextUp.name)
                                    .font(.headline)
                                Text("Up Next")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                )
                .scaleEffect(showContent ? 1 : 0.9)
                .opacity(showContent ? 1 : 0)

                // Rotation info
                HStack(spacing: 8) {
                    Image(systemName: "repeat")
                        .foregroundStyle(.green)
                    Text("Rotation \(viewModel.rotationCount)")
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Image(systemName: "timer")
                        .foregroundStyle(.blue)
                    Text(turnDurationText)
                }
                .font(.callout.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(.ultraThinMaterial))
                .opacity(showContent ? 1 : 0)

                // Ready button with glow
                Button {
                    viewModel.acknowledgeRotation()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "keyboard")
                        Text("Ready to Drive!")
                    }
                    .font(.headline)
                    .frame(minWidth: 200)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
                .keyboardShortcut(.return, modifiers: [])
                .shadow(color: .green.opacity(pulseReady ? 0.5 : 0.2), radius: pulseReady ? 15 : 5)
                .scaleEffect(pulseReady ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseReady)
                .scaleEffect(showContent ? 1 : 0.9)
                .opacity(showContent ? 1 : 0)

                // Secondary actions
                HStack(spacing: 32) {
                    Button {
                        viewModel.skipTurn()
                    } label: {
                        Label("Skip Turn", systemImage: "forward.fill")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))

                    Button {
                        viewModel.pause()
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding(.horizontal, 40)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .topTrailing) {
            // Dismiss button (top-right corner)
            Button {
                viewModel.pause()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(12)
            .keyboardShortcut(.escape, modifiers: [])
            .help("Dismiss and pause (Esc)")
        }
        .onAppear {
            currentEncouragement = encouragements.randomElement() ?? encouragements[0]
            isAnimating = true
            pulseReady = true
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
        }
    }

    private var turnDurationText: String {
        let seconds = viewModel.settings.effectiveRotationSeconds
        if seconds >= 60 {
            let minutes = seconds / 60
            return "\(minutes) min turn"
        } else {
            return "\(seconds) sec turn"
        }
    }
}

#Preview {
    let viewModel = TimerViewModel()
    return RotationWindowView(viewModel: viewModel)
        .onAppear {
            viewModel.addParticipant(name: "Alice")
            viewModel.addParticipant(name: "Bob")
            viewModel.addParticipant(name: "Charlie")
        }
}
