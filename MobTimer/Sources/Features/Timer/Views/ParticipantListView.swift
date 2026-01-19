import SwiftUI
import UniformTypeIdentifiers

struct ParticipantListView: View {
    @Bindable var viewModel: TimerViewModel

    @State private var newParticipantName: String = ""
    @State private var isAddingParticipant: Bool = false
    @State private var dropTargetID: UUID?
    @State private var draggedParticipantID: UUID?

    private var activeParticipants: [Participant] {
        viewModel.participants.filter { !$0.isAway }
    }

    private var awayParticipants: [Participant] {
        viewModel.participants.filter { $0.isAway }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Participants")
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }

            // Active participants section
            if activeParticipants.isEmpty && awayParticipants.isEmpty {
                Text("No participants yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else if activeParticipants.isEmpty {
                Text("No active participants")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(Array(activeParticipants.enumerated()), id: \.element.id) { index, participant in
                    ParticipantRowView(
                        participant: participant,
                        isDriver: viewModel.currentDriver?.id == participant.id,
                        isEditing: viewModel.editingParticipantID == participant.id,
                        isDropTarget: false,
                        canMoveUp: index > 0,
                        canMoveDown: index < activeParticipants.count - 1,
                        onUpdate: { updated in
                            viewModel.updateParticipant(updated)
                        },
                        onToggleAway: {
                            viewModel.toggleAway(for: participant)
                        },
                        onDelete: {
                            viewModel.removeParticipant(participant)
                        },
                        onStartEditing: {
                            viewModel.editingParticipantID = participant.id
                        },
                        onEndEditing: {
                            viewModel.editingParticipantID = nil
                        },
                        onMoveUp: {
                            viewModel.moveParticipantUp(participant.id)
                        },
                        onMoveDown: {
                            viewModel.moveParticipantDown(participant.id)
                        }
                    )
                }
            }

            // Away participants section
            if !awayParticipants.isEmpty {
                awaySectionView
            }

            Divider()

            if isAddingParticipant {
                HStack {
                    TextField("Name", text: $newParticipantName)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            addParticipant()
                        }

                    Button {
                        addParticipant()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                    .disabled(newParticipantName.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button {
                        cancelAdd()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
            } else {
                Button {
                    isAddingParticipant = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Participant")
                    }
                    .font(.callout)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }
        }
    }

    private var awaySectionView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "moon.zzz.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("Away")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            FlowLayout(spacing: 6) {
                ForEach(awayParticipants) { participant in
                    Button {
                        viewModel.toggleAway(for: participant)
                    } label: {
                        HStack(spacing: 4) {
                            Text(participant.name)
                                .font(.caption)
                            Image(systemName: "plus.circle.fill")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Bring \(participant.name) back to rotation")
                }
            }
        }
    }

    private func addParticipant() {
        let name = newParticipantName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        viewModel.addParticipant(name: name)
        newParticipantName = ""
        isAddingParticipant = false
    }

    private func cancelAdd() {
        newParticipantName = ""
        isAddingParticipant = false
    }
}

#Preview {
    let viewModel = TimerViewModel()

    ParticipantListView(viewModel: viewModel)
        .padding()
        .frame(width: 300)
        .onAppear {
            viewModel.addParticipant(name: "Alice")
            viewModel.addParticipant(name: "Bob")
            viewModel.addParticipant(name: "Charlie")
        }
}

struct ParticipantDropDelegate: DropDelegate {
    let targetParticipantID: UUID
    @Binding var draggedParticipantID: UUID?
    @Binding var dropTargetID: UUID?
    let onMove: (UUID, UUID) -> Void

    func validateDrop(info: DropInfo) -> Bool {
        print("🔵 VALIDATE DROP on \(targetParticipantID), hasItemsConforming: \(info.hasItemsConforming(to: [UTType.text]))")
        return true
    }

    func dropEntered(info: DropInfo) {
        print("🟡 DROP ENTERED: target=\(targetParticipantID), dragged=\(String(describing: draggedParticipantID))")
        dropTargetID = targetParticipantID
    }

    func dropExited(info: DropInfo) {
        print("🟠 DROP EXITED: target=\(targetParticipantID)")
        dropTargetID = nil
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        print("🔴 PERFORM DROP: target=\(targetParticipantID), dragged=\(String(describing: draggedParticipantID))")
        guard let draggedID = draggedParticipantID else {
            print("❌ PERFORM DROP FAILED: draggedParticipantID is nil")
            return false
        }
        if draggedID != targetParticipantID {
            print("✅ MOVING \(draggedID) before \(targetParticipantID)")
            onMove(draggedID, targetParticipantID)
        } else {
            print("⚠️ SAME TARGET - no move needed")
        }
        draggedParticipantID = nil
        dropTargetID = nil
        return true
    }
}
