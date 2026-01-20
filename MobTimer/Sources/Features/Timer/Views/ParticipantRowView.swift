import SwiftUI

struct ParticipantRowView: View {
    let participant: Participant
    let isDriver: Bool
    let isEditing: Bool
    var isDropTarget: Bool = false
    var canMoveUp: Bool = false
    var canMoveDown: Bool = false
    var intellijIntegrationEnabled: Bool = false
    var availableKeymaps: [String] = IntelliJService.commonKeymaps
    let onUpdate: (Participant) -> Void
    let onToggleAway: () -> Void
    let onDelete: () -> Void
    let onStartEditing: () -> Void
    let onEndEditing: () -> Void
    var onMoveUp: (() -> Void)?
    var onMoveDown: (() -> Void)?

    @State private var editedName: String = ""
    @State private var selectedKeymap: String = ""

    var body: some View {
        HStack(spacing: 8) {
            // Reorder buttons
            VStack(spacing: 0) {
                Button {
                    onMoveUp?()
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 9, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(canMoveUp ? .secondary : .quaternary)
                .disabled(!canMoveUp)

                Button {
                    onMoveDown?()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(canMoveDown ? .secondary : .quaternary)
                .disabled(!canMoveDown)
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("Name", text: $editedName)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                commitEdit()
                            }

                        Button {
                            commitEdit()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)

                        Button {
                            onEndEditing()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    if intellijIntegrationEnabled {
                        HStack {
                            Text("Keymap:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("", selection: $selectedKeymap) {
                                Text("None").tag("")
                                ForEach(availableKeymaps, id: \.self) { keymap in
                                    Text(keymap).tag(keymap)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(maxWidth: 150)
                        }
                    }
                }
                .onAppear {
                    editedName = participant.name
                    selectedKeymap = participant.intellijKeymap ?? ""
                }
            } else {
                Text(participant.name)
                    .foregroundStyle(participant.isAway ? .secondary : .primary)

                if intellijIntegrationEnabled, let keymap = participant.intellijKeymap {
                    Text(abbreviateKeymap(keymap))
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                Spacer()

                if isDriver {
                    Text("driving")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }

                Button {
                    onStartEditing()
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button {
                    onToggleAway()
                } label: {
                    Image(systemName: participant.isAway ? "moon.fill" : "figure.run")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(participant.isAway ? .orange : .secondary)
                .help(participant.isAway ? "Mark as active" : "Mark as away")

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isDropTarget ? Color.accentColor.opacity(0.3) : (participant.isAway ? Color.secondary.opacity(0.1) : Color.clear))
        )
        .overlay(alignment: .top) {
            if isDropTarget {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 3)
            }
        }
    }

    private func commitEdit() {
        guard !editedName.trimmingCharacters(in: .whitespaces).isEmpty else {
            onEndEditing()
            return
        }

        var updated = participant
        updated.name = editedName.trimmingCharacters(in: .whitespaces)
        updated.intellijKeymap = selectedKeymap.isEmpty ? nil : selectedKeymap
        onUpdate(updated)
        onEndEditing()
    }

    private func abbreviateKeymap(_ keymap: String) -> String {
        switch keymap {
        case "macOS": return "macOS"
        case "macOS System Shortcuts": return "macSys"
        case "IntelliJ IDEA Classic": return "IJ"
        case "Eclipse": return "Ecl"
        case "Eclipse (macOS)": return "Ecl-M"
        case "Visual Studio": return "VS"
        case "VSCode": return "VSC"
        case "VSCode (macOS)": return "VSC-M"
        case "Sublime Text": return "Subl"
        case "Sublime Text (macOS)": return "Subl-M"
        case "Emacs": return "Emacs"
        case "NetBeans": return "NB"
        default:
            // For unknown keymaps, take first 6 characters
            return String(keymap.prefix(6))
        }
    }
}

#Preview {
    VStack {
        ParticipantRowView(
            participant: Participant(name: "Alice"),
            isDriver: true,
            isEditing: false,
            onUpdate: { _ in },
            onToggleAway: {},
            onDelete: {},
            onStartEditing: {},
            onEndEditing: {}
        )

        ParticipantRowView(
            participant: Participant(name: "Bob", isAway: true),
            isDriver: false,
            isEditing: false,
            onUpdate: { _ in },
            onToggleAway: {},
            onDelete: {},
            onStartEditing: {},
            onEndEditing: {}
        )
    }
    .padding()
}
