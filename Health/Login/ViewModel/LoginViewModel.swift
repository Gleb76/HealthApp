
import SwiftUI
import Firebase
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

class LoginViewModel: ObservableObject {
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    @Published var nonce: String = ""
    
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var isAuthenticated = false
    
    func getOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                Auth.auth().settings?.appVerificationDisabledForTesting = true
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber(
                    "+\(mobileNo)", uiDelegate: nil
                )
                await MainActor.run {
                    CLIENT_CODE = code
                    withAnimation(.easeInOut) {
                        showOTPField.toggle()
                    }
                    
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                try await Auth.auth().signIn(with: credential)
                await MainActor.run {
                    isAuthenticated = true
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func handleError(error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            
        }
    }
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        guard let appleIDToken = credential.identityToken else {
            self.errorMessage = "Unable to fetch identity token"
            self.showError = true
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            self.errorMessage = "Unable to serialize token string from data"
            self.showError = true
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        Task {
            do {
                try await Auth.auth().signIn(with: firebaseCredential)
                await MainActor.run {
                    isAuthenticated = true
                }
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func signInWithGoogle() async {
           guard let clientID = FirebaseApp.app()?.options.clientID else {
               await handleError(error: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found"]))
               return
           }
           
           let config = GIDConfiguration(clientID: clientID)
           GIDSignIn.sharedInstance.configuration = config
           
           guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                 let window = windowScene.windows.first,
                 let rootViewController = window.rootViewController else {
               await handleError(error: NSError(domain: "GoogleSignIn", code: -2, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"]))
               return
           }
           
           do {
               let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
               
               let user = userAuthentication.user
               guard let idToken = user.idToken?.tokenString else {
                   throw NSError(domain: "GoogleSignIn", code: -3, userInfo: [NSLocalizedDescriptionKey: "ID token missing"])
               }
               
               let accessToken = user.accessToken.tokenString
               let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
               
               try await Auth.auth().signIn(with: credential)
               await MainActor.run {
                   isAuthenticated = true
               }
               
           } catch {
               await handleError(error: error)
           }
       }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
