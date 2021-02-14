import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:treehacks2021/screens/group_screens/groups.dart';
import 'package:treehacks2021/screens/profile_screen.dart';
import 'package:treehacks2021/screens/welcome_screen.dart';
import 'package:treehacks2021/screens/login_screen.dart';
import 'package:treehacks2021/screens/registration_screen.dart';
import 'package:treehacks2021/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  /* await FirebaseFirestore.instance.clearPersistence()
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);*/
  //Code for disabling persistence when firestore is used
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        GroupScreen.id: (context) => GroupScreen(),
      },
    );
  }
}
