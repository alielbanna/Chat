import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui_starter/screens/home_screen.dart';
import 'package:flutter_chat_ui_starter/screens/profile_screen.dart';
import 'package:flutter_chat_ui_starter/screens/welcome_screen.dart';
import 'package:flutter_chat_ui_starter/screens/chat_screen.dart';
import 'package:flutter_chat_ui_starter/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_ui_starter/services/navigation_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  //App's Ui 
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFF125589),
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  //Firebase iniatialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  runApp(MyApp());
}
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Prevent screen rotation inside the app
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    //Material App
    return MaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.transparent,
        primaryColor: Colors.white,
        accentColor: Color(0xFF125589),
      ),
      navigatorKey: NavigationService.instance.navigatorKey,
      initialRoute: LoginScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}

//Color(0xFFEDF6F9),
