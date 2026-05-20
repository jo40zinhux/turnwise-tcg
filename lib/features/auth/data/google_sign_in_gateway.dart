import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_oauth_config.dart';

/// Centralized Google Sign-In configuration (web client ID + iOS client ID).
class GoogleSignInGateway {
  GoogleSignInGateway._();

  static final GoogleSignIn instance = GoogleSignIn(
    clientId: (!kIsWeb && Platform.isIOS)
        ? AuthOAuthConfig.googleIosClientId
        : null,
    serverClientId: AuthOAuthConfig.googleWebClientId,
    scopes: const ['email', 'profile'],
  );
}
