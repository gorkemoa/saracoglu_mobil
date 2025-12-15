import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google ile giriş yap
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  /// Google oturumunu kapat
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Apple ile giriş yap
  Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return credential;
    } catch (e) {
      print('Apple Sign In Error: $e');
      return null;
    }
  }
}
