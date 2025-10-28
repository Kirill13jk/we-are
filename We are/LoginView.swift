import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                HStack {
                    Button(action: { appState.isOnboardingDone = false }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                    .tint(.accentColor)
                    Spacer()
                }
                .padding(.top, 8)

                // Логотип
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 84)
                    .padding(.top, 32)

                // Поля
                Group {
                    TextField("alex@gmail.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .modifier(FilledField())
                        .padding(.top, 50)

                    ZStack {
                        Group {
                            if showPassword {
                                TextField("••••••", text: $password)
                            } else {
                                SecureField("••••••", text: $password)
                            }
                        }
                        .modifier(FilledField())

                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .font(.body)
                                .padding(.trailing, 12)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }

                // Кнопка "Войти" -> главный
                Button(action: goToMain) {
                    Text("Войти")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(radius: 1, y: 1)
                }
                .padding(.top, 4)
                
                Spacer()

                // "Забыли пароль?"
                Button("Забыли пароль?") { /*TODO*/ }
                    .font(.subheadline)
                    .tint(.accentColor)
                    .padding(.top, 50)

                // Разделитель "или"
                HStack(spacing: 12) {
                    DividerLine()
                    Text("или").foregroundStyle(.secondary)
                    DividerLine()
                }

                // Соц-кнопки (заглушки)
                HStack(spacing: 12) {
                    SocialSquare(text: "f") { /*TODO*/ }
                    SocialSquare(systemImage: "apple.logo") { /*TODO*/ }
                    SocialSquare(text: "G") { /*TODO*/ }
                }

                // Войти как гость -> главный
                Button(action: goToMain) {
                    Text("Войти как гость")
                        .font(.subheadline)
                        .underline()
                        .tint(.primary)
                }
                .padding(.top, 4)

                // Регистрация
                HStack(spacing: 4) {
                    Text("Нет аккаунта?")
                        .foregroundStyle(.secondary)
                    Button("Зарегистрироваться") { /*TODO*/ }
                        .font(.subheadline)
                        .tint(.accentColor)
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
        }
        .tint(.accentColor)
        .navigationBarBackButtonHidden(true)
    }

    private func goToMain() {
        withAnimation(.easeInOut) {
            appState.isAuthorized = true
        }
    }
}

// MARK: - UI helpers

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(.secondary.opacity(0.25))
    }
}

private struct SocialSquare: View {
    var systemImage: String?
    var text: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(height: 52)

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(.primary)
                } else if let text {
                    Text(text)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
