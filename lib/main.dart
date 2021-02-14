import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:treehacks2021/screens/group_screens/group_chat.dart';
import 'package:treehacks2021/screens/group_screens/group_create.dart';
import 'package:treehacks2021/screens/group_screens/group_minigames.dart';
import 'package:treehacks2021/screens/group_screens/groups.dart';
import 'package:treehacks2021/screens/profile_screen.dart';
import 'package:treehacks2021/screens/welcome_screen.dart';
import 'package:treehacks2021/screens/login_screen.dart';
import 'package:treehacks2021/screens/registration_screen.dart';
import 'package:treehacks2021/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:treehacks2021/workout_screens/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  dynamic cameras = await availableCameras();
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
        GroupChat.id: (context) => GroupChat(),
        GroupCreate.id: (context) => GroupCreate(),
        GroupMinigames.id: (context) => GroupMinigames(),
        GroupScreen.id: (context) => GroupScreen(),
        CameraScreen.id: (context) => CameraScreen(),
      },
    );
  }
}

class NavigationUtil {
  static Future<MyNavigationResult> pushNamed<T>(
      BuildContext context, String routeName,
      [T arguments]) async {
    return (await Navigator.pushNamed(context, routeName, arguments: arguments))
    as MyNavigationResult;
  }

  static void pop(BuildContext context, MyNavigationResult result) {
    Navigator.pop(context, result);
  }

  static void navigate(BuildContext context,
      [String route,
        Object arguments,
        void Function(MyNavigationResult) onReturn]) {
    if (route == null) {
      NavigationUtil.pop(context, null);
    } else {
      NavigationUtil.pushNamed(context, route, arguments).then((result) {
        onReturn?.call(result);
        result?.apply(context, null);
      });
    }
  }

  static void navigateWithRefresh(
      BuildContext context, String route, void Function() refresh,
      [Object arguments]) {
    NavigationUtil.pushNamed(context, route, arguments).then((result) {
      final modifiedResult = result ?? MyNavigationResult();
      modifiedResult.refresh = true;
      modifiedResult.apply(context, refresh);
    });
  }
}

class MyNavigationResult {
  String message;
  Object returnValue;
  bool refresh;
  MyNavigationResult pop;

  void apply(BuildContext context, [void Function() doRefresh]) {
    print('TESTING');
    print(doRefresh);
    print(refresh);
    if (pop != null) {
      NavigationUtil.pop(context, pop);
    } else {
      if (message != null) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
      if (refresh == true) {
        print("Got into refresh");
        doRefresh();
      }
    }
  }
}
