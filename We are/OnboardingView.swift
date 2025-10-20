import SwiftUI

struct OnboardingPage: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let title: String
}

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selection = 0

    private let pages: [OnboardingPage] = [
        .init(imageName: "onb_1", title: "Будь в курсе о своём заведении!"),
        .init(imageName: "onb_3", title: "Оставляй отзывы!"),
        .init(imageName: "onb_2", title: "Развивайся вместе с нами!")
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                        OnboardingSlide(page: page)
                            .tag(idx)
                            .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 16) {
                    DotsIndicator(count: pages.count, currentIndex: selection)

                    if selection == pages.count - 1 {
                        Button(action: finish) {
                            Text("Начать!")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(radius: 1, y: 1)
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.vertical, 20)
                .animation(.easeInOut(duration: 0.25), value: selection)
            }

            if selection < pages.count - 1 {
                Button("Пропустить") { finish() }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .tint(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .safeAreaPadding(.bottom, 8)
    }

    private func finish() {
        withAnimation(.easeInOut) { appState.isOnboardingDone = true }
    }
}

struct OnboardingSlide: View {
    let page: OnboardingPage

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: min(geo.size.height * 0.45, 360))
                    .accessibilityHidden(true)

                Spacer().frame(height: 32)

                Text(page.title)
                    .font(.system(size: 25, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(3)
                    .padding(.horizontal, 12)
                    .accessibilityLabel(page.title)
                    .foregroundStyle(Color.accentColor)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct DotsIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .frame(width: i == currentIndex ? 8 : 7, height: i == currentIndex ? 8 : 7)
                    .foregroundStyle(i == currentIndex ? Color.accentColor : Color.secondary.opacity(0.35))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentIndex)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(count)")
    }
}
