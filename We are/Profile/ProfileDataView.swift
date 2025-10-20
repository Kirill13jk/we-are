import SwiftUI
import PhotosUI

struct ProfileDataView: View {
    @EnvironmentObject private var profile: ProfileModel
    @Environment(\.dismiss) private var dismiss

    // черновики (чтобы не применять изменения до "Сохранить")
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var middleName = ""
    @State private var email = ""
    @State private var newPassword = ""

    @State private var avatarDraft: UIImage?
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Аватар + кнопка камеры
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            avatarView
                                .frame(width: 108, height: 108)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(radius: 3, y: 1)

                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 28, height: 28)
                                .overlay(Image(systemName: "camera.fill").font(.footnote).foregroundStyle(.white))
                                .offset(x: 4, y: 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    }
                    .onChange(of: pickerItem) { _, item in
                        Task {
                            if let data = try? await item?.loadTransferable(type: Data.self),
                               let ui = UIImage(data: data) {
                                avatarDraft = ui
                            }
                        }
                    }

                    Group {
                        LabeledField("Имя") {
                            TextField("Анна", text: $firstName)
                                .modifier(FilledField())
                        }
                        LabeledField("Фамилия") {
                            TextField("Иванова", text: $lastName)
                                .modifier(FilledField())
                        }
                        LabeledField("Отчество") {
                            TextField("Ивановна", text: $middleName)
                                .modifier(FilledField())
                        }
                        LabeledField("Почта") {
                            TextField("skillhub@gmail.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .modifier(FilledField())
                        }
                        LabeledField("Пароль") {
                            SecureField("••••••", text: $newPassword)
                                .modifier(FilledField())
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 120)
                
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Данные")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button(action: save) {
                    Text("Сохранить")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .foregroundStyle(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(radius: 2, y: 1)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        
            .onAppear(perform: loadDrafts)
            .scrollDismissesKeyboard(.interactively)
            
        }
    

    @ViewBuilder
    private var avatarView: some View {
        if let img = avatarDraft ?? profile.avatar {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Image(systemName: "person.circle.fill")
                .resizable().scaledToFill()
                .foregroundStyle(.secondary)
        }
    }

    private func loadDrafts() {
        firstName = profile.firstName
        lastName = profile.lastName
        middleName = profile.middleName
        email = profile.email
        avatarDraft = profile.avatar
    }

    private func save() {
        profile.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.lastName  = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.middleName = middleName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.email     = email.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.avatar    = avatarDraft
        profile.persist()
        dismiss()
    }

}

// MARK: - Локальные UI-хелперы

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

