import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_diary/generated/l10n.dart';

class User with ChangeNotifier {
  GoogleSignInAccount? signInAccount;
  bool isAnonymous = false;
  String displayName = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    scopes: <String>[
      'email',
    ],
  );

  User() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      updateFromGoogleSignIn(account);
    });
  }

  get isLogged => isAnonymous || id != null;
  get id => signInAccount?.id;
  get email => signInAccount?.email ?? '';
  get serverAuthCode => signInAccount?.serverAuthCode;

  Future<void> signInWithGoogle() {
    return _googleSignIn.signIn();
  }

  Future<GoogleSignInAccount?> signInSilentlyWithGoogle() {
    return _googleSignIn.signInSilently();
  }

  void signInAsAnonymous(BuildContext context) {
    updateFromAnonymousSignIn(context);
  }

  void updateFromGoogleSignIn(GoogleSignInAccount? account) {
    signInAccount = account;
    isAnonymous = false;
    displayName = signInAccount?.displayName ?? '';
    notifyListeners();
  }

  void updateFromAnonymousSignIn(BuildContext context) {
    signInAccount = null;
    isAnonymous = true;
    displayName = S.of(context).anonymous;
    notifyListeners();
  }

  void logout() async {
    if (signInAccount != null) {
      await _googleSignIn.disconnect();
    }

    signInAccount = null;
    isAnonymous = false;
    notifyListeners();
  }
}