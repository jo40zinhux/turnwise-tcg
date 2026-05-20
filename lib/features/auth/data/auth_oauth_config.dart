/// OAuth client IDs and Firebase Auth redirect configuration.
///
/// Apple Return URL (Apple Developer): https://turnwise-tcg.firebaseapp.com/__/auth/handler
abstract final class AuthOAuthConfig {
  /// Web client ID — required as [GoogleSignIn.serverClientId] on Android for idToken.
  static const googleWebClientId =
      '1057324438192-4l0fn5h94oauv94430orbc7lmuv3sf17.apps.googleusercontent.com';

  /// iOS client ID from GoogleService-Info.plist / firebase_options.
  static const googleIosClientId =
      '1057324438192-5u4jmtuvgdjo7on8cuil8mgpn7a7ftgs.apps.googleusercontent.com';

  /// URL scheme for Google Sign-In on iOS (REVERSED_CLIENT_ID).
  static const googleIosUrlScheme =
      'com.googleusercontent.apps.1057324438192-5u4jmtuvgdjo7on8cuil8mgpn7a7ftgs';
}
