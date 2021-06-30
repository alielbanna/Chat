import 'package:flutter/material.dart';

class NavigationService {
  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  GlobalKey<NavigatorState> navigatorKey;
  static NavigationService instance = NavigationService();

  Future<dynamic> navigateToReplacement(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute route) {
    return navigatorKey.currentState.push(route);
  }

  void goBack() {
    return navigatorKey.currentState.pop();
  }
}
