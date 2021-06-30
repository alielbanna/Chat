import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/animations/fade_animation.dart';
import 'package:flutter_chat_ui_starter/services/permission.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:flutter_chat_ui_starter/services/snackbar_service.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //final auth = FirebaseAuth.instance;
  String email;
  String password;
  AuthProvider _auth;
  bool showSpinner = false;
  @override
  void initState() {
    permissionVoice(context);
    permissionStorage(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: Builder(
            builder: (BuildContext context) {
              SnackBarService.instance.buildContext = context;
              _auth = Provider.of<AuthProvider>(context);
              return SingleChildScrollView(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeAnimation(
                            delay: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15.0),
                                  bottomRight: Radius.circular(15.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 60.0,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontFamily: 'RobotoSlab',
                                        color: Colors.white,
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    FadeAnimation(
                                      delay: 1.3,
                                      child: Text(
                                        'Welcome Back',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          height: 1.4,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Container(
                          color: Color(0xFFEEEEEE),
                          child: Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                FadeAnimation(
                                  delay: 1.4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFDDE4F5)
                                              .withOpacity(0.3),
                                          blurRadius: 20.0,
                                          offset: Offset(0.0, 10.0),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]),
                                            ),
                                          ),
                                          child: Form(
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            child: TextFormField(
                                              validator: (value) => value
                                                              .length !=
                                                          0 &&
                                                      value.contains('@')
                                                  ? null
                                                  : 'Please enter a valid email',
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              onChanged: (value) {
                                                setState(() {
                                                  email = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter your email',
                                                hintStyle: TextStyle(
                                                    color: Colors.blueGrey),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]),
                                            ),
                                          ),
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            obscureText: true,
                                            onChanged: (value) {
                                              setState(() {
                                                password = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: TextStyle(
                                                  color: Colors.blueGrey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                FadeAnimation(
                                  delay: 1.5,
                                  child: Text(
                                    'Remember: The password should be your National ID!',
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.0,
                                ),
                                FadeAnimation(
                                  delay: 1.6,
                                  child: _auth.status ==
                                          AuthStatus.Authenticating
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(),
                                        )
                                      : GestureDetector(
                                          child: Container(
                                            height: 50,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 100.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                color: Theme.of(context)
                                                    .accentColor),
                                            child: Center(
                                              child: Text(
                                                'Login',
                                                style: TextStyle(
                                                    fontFamily: 'RobotoSlab',
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            _auth.loginUserWithEmailAndPassword(
                                                email.trim(), password);
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
