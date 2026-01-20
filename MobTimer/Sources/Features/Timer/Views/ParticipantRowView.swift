import SwiftUI

struct ParticipantRowView: View {
    let participant: Participant
    let isDriver: Bool
    let isEditing: Bool
    var canMoveUp: Bool = false
    var canMoveDown: Bool = false
    var showEmailField: Bool = false
    let onUpdate: (Participant) -> Void
    let onToggleAway: () -> Void
    let onDelete: () -> Void
    let onStartEditing: () -> Void
    let onEndEditing: () -> Void
    var onMoveUp: (() -> Void)?
    var onMoveDown: (() -> Void)?

    @State private var editedName: String = ""
    @State private var editedEmail: String = ""

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
                    TextField("Name", text: $editedName)
                        .textFieldStyle(.plain)
                    if showEmailField {
                        TextField("Email", text: $editedEmail)
                            .textFieldStyle(.plain)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onAppear {
                    editedName = participant.name
                    editedEmail = participant.email
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
            } else {
                Text(participant.name)
                    .foregroundStyle(participant.isAway ? .secondary : .primary)

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
                .fill(participant.isAway ? Color.secondary.opacity(0.1) : Color.clear)
        )
    }

    private func commitEdit() {
        guard !editedName.trimmingCharacters(in: .whitespaces).isEmpty else {
            onEndEditing()
            return
        }

        var updated = participant
        updated.name = editedName.trimmingCharacters(in: .whitespaces)
        updated.email = editedEmail.trimmingCharacters(in: .whitespaces)
        onUpdate(updated)
        onEndEditing()
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
