import SwiftUI

struct LevelPickerSheet: View {
    @Binding var selected: ProficiencyLevel?
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            List {
                // В шите НЕ показываем "Родной" — он для карточки, а не CEFR
                ForEach(ProficiencyLevel.allCases.filter { $0 != .native }) { level in
                    HStack(spacing: 12) {
                        RadioCircle(isOn: selected == level)
                        Text(level.title)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selected = level }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Уровень владения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.45), .large])
        .presentationDragIndicator(.visible)
    }
}
