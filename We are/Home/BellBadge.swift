// BellBadge.swift
import SwiftUI

public struct BellBadge: View {
    public var count: Int
    public init(count: Int) { self.count = count }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // сам колокольчик. Даем стабильный фрейм 44×44 как в nav bar
            Image(systemName: "bell")
                .font(.title3)
                .frame(width: 44, height: 44) // без белого пузыря

            if count > 0 {
                Text("\(min(count, 99))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.red))
                    // смещаем ВНУТРЬ кнопки, чтобы не упирался в правый край
                    .offset(x: -6, y: 6)
            }
        }
        .contentShape(Rectangle())
        .accessibilityLabel("Непрочитанных: \(count)")
    }
}
