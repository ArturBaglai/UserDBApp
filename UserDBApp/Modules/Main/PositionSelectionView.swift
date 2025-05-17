import SwiftUI

struct PositionSelectionView: View {
    
    @EnvironmentObject private var positionSelectionViewModel: PositionSelectionViewModel
    @Binding var selectedOption: String
    @Binding var positionId: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("Select your position:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !positionSelectionViewModel.positionsLoading {
                ForEach(positionSelectionViewModel.positions.indices, id: \.self) { index in
                    let position = positionSelectionViewModel.positions[index]

                    HStack {
                        RadioButton(isSelected: selectedOption == position)
                            .onTapGesture {
                                selectPosition(at: index)
                            }

                        Text(position)
                            .foregroundColor(.primary)
                            .onTapGesture {
                                selectPosition(at: index)
                            }
                        Spacer()
                    }
                    .frame(width: 328, height: 48)
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                }
            } else {
                Text("Positions are loading...")
            }
        }
        .padding()

        if let positionError = positionSelectionViewModel.validationErrors?["position_id"]?.first {
            Text(positionError)
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    private func selectPosition(at index: Int) {
        positionId = positionSelectionViewModel.positionIds[index]
        selectedOption = positionSelectionViewModel.positions[index]
    }
}

struct RadioButton: View {
    
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.blueRadioButton : .gray, lineWidth: isSelected ? 4 : 1)
                .frame(width: 14, height: 14)

            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
        }
    }
}
