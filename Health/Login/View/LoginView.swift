import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @StateObject var loginViewModel: LoginViewModel = .init()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 24) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                           
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("Sign in to continue your health journey")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    
                    // Form Section
                    VStack(spacing: 24) {
                        // Phone Number Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                TextField("+1 650-555-1234", text: $loginViewModel.mobileNo)
                                    .keyboardType(.phonePad)
                                    .disabled(loginViewModel.showOTPField)
                                    .opacity(loginViewModel.showOTPField ? 0.6 : 1)
                                
                                if loginViewModel.showOTPField {
                                    Button(action: {
                                        withAnimation(.spring) {
                                            loginViewModel.showOTPField = false
                                            loginViewModel.otpCode = ""
                                            loginViewModel.CLIENT_CODE = ""
                                        }
                                    }) {
                                        Text("Edit")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.indigo)
                                    }
                                    .transition(.opacity)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // OTP Field (Conditional)
                        if loginViewModel.showOTPField {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Verification Code")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                TextField("Enter OTP", text: $loginViewModel.otpCode)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Action Button
                        Button(action: {
                            loginViewModel.showOTPField ? loginViewModel.verifyOTPCode() : loginViewModel.getOTPCode()
                        }) {
                            HStack(spacing: 12) {
                                Text(loginViewModel.showOTPField ? "Verify Code" : "Get Verification Code")
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right")
                                    .font(.footnote)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.indigo, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .indigo.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    
                    // Social Login Section
                    VStack(spacing: 16) {
                        Text("or continue with")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                        
                        // Social Buttons
                        VStack(spacing: 16) {
                            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(
                                scheme: colorScheme == .dark ? .light : .dark,
                                style: .wide,
                                state: .normal
                            )) {
                                Task {
                                    await loginViewModel.signInWithGoogle()
                                }
                            }
                            .frame(height: 50)
                            
                            SignInWithAppleButton(.signIn) { request in
                                loginViewModel.nonce = randomNonceString()
                                request.requestedScopes = [.email, .fullName]
                                request.nonce = sha256(loginViewModel.nonce)
                            } onCompletion: { result in
                                Task {
                                    await handleAppleSignInResult(result)
                                }
                            }
                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .alert(loginViewModel.errorMessage, isPresented: $loginViewModel.showError) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authResults):
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                loginViewModel.authenticate(credential: appleIDCredential)
            default:
                break
            }
        case .failure(let error):
            await loginViewModel.handleError(error: error)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    LoginView()
}
