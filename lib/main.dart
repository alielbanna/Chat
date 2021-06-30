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
