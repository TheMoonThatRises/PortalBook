//
//  LoginView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/9/23.
//

import SwiftUI
import AlertToast
import StudentVue

enum LoginField {
    case username, password
}

struct LoginView: View {
    @Binding var client: StudentVue

    @Binding var viewIndex: ViewIndex

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var username = ""
    @State var password = ""

    @FocusState var focusedField: LoginField?

    @State var rememberLogin = Settings.shared.$rememberLogin

    var loggingIn: Bool {
        loadingMessage == .loggingIn
    }

    var disableUIElements: Bool {
        loggingIn || username.isEmpty || password.isEmpty
    }

    var body: some View {
        GeometryReader { viewGeom in
            ScrollView {
                Text("StudentVue Login via PortalBook")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                Text(Settings.shared.domain)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

                Spacer()
                    .padding()

                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .frame(width: viewGeom.size.width / 2, height: viewGeom.size.width / 2)
                    .cornerRadius(7.5)

                Spacer()
                    .padding()

                VStack(alignment: .leading, spacing: 15) {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .username)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(focusedField == .username ? .blue : .gray, lineWidth: 2)
                        }
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .password)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(focusedField == .password ? .blue : .gray, lineWidth: 2)
                        }
                }
                .textInputAutocapitalization(.never)
                .padding([.leading, .trailing], 27.5)
                .disabled(loggingIn)

                Toggle(isOn: rememberLogin, label: {
                    Text("Remember me")
                })
                .padding([.leading, .trailing], 27.5)
                .disabled(loggingIn)

                Spacer()
                    .padding()

                Button(action: { withAnimation(.easeInOut) { login() } }, label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: viewGeom.size.width / 1.5, minHeight: viewGeom.size.height / 50)
                        .background(disableUIElements ? .gray : .blue)
                        .cornerRadius(5)
                })
                .disabled(disableUIElements)

                Spacer()
                    .padding()

                Button(action: { withAnimation(.easeInOut) {
                    viewIndex = .districtView
                }}, label: {
                    Text("Back to District Selector")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding()
                        .background(loggingIn ? .gray : .blue)
                        .cornerRadius(5)
                })
                .disabled(loggingIn)
            }
        }
    }

    func login() {
        loadingMessage = .loggingIn
        focusedField = nil

        Task {
            defer {
                loadingMessage = .empty
            }

            client.updateCredentials(domain: Settings.shared.domain, username: username, password: password)

            do {
                Settings.shared.didManuallyLogout = false

                _ = try await client.scraper.login()

                withAnimation(.easeInOut) {
                    viewIndex = .homeView
                }

                if rememberLogin.wrappedValue {
                    try await PortalKeychain.shared.save(username: username,
                                                         password: password,
                                                         domain: StudentVue.domain)
                }

                username = ""
                password = ""
            } catch {
                switch error {
                case StudentVueScraper.ScraperErrors.invalidUsername:
                    focusedField = .username
                case StudentVueScraper.ScraperErrors.incorrectPassword:
                    focusedField = .password
                default:
                    break
                }

                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView(
        client: .constant(StudentVue(domain: "test.edupoint.com", username: "", password: "")),
        viewIndex: .constant(.loginView),
        loadingMessage: .constant(.empty),
        errorMessage: .constant("")
    )
}
