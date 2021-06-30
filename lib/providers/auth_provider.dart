import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui_starter/screens/home_screen.dart';
import 'package:flutter_chat_ui_starter/screens/login_screen.dart';
import 'package:flutter_chat_ui_starter/services/navigation_service.dart';
import 'package:flutter_chat_ui_starter/services/snackbar_service.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  FirebaseAuth _auth;
  AuthStatus status;
  User user;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    checkCurrentUserIsAuthenticated();
  }

  void autoLogin() async {
    if (user != null) {
      await DatabaseService.instance.updateUserLastSeenTime(user.uid);
      return NavigationService.instance.navigateToReplacement(HomeScreen.id);
    }
  }

  void checkCurrentUserIsAuthenticated() {
    user = _auth.currentUser;
    if (user != null) {
      notifyListeners();
      autoLogin();
    }
  }

  void loginUserWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess('welcome, ${user.email}');
      await DatabaseService.instance.updateUserLastSeenTime(user.uid);
      await DatabaseService.instance.updateUsertoken(user.uid);
      NavigationService.instance.navigateToReplacement(HomeScreen.id);
    } catch (e) {
      user = null;
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError('Error Authenticating!');
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement(LoginScreen.id);
      //SnackBarService.instance.showSnackBarSuccess('Logged Out Successfully!');
    } catch (e) {
      SnackBarService.instance.showSnackBarError('Error Logging Out');
    }
    notifyListeners();
  }
}
