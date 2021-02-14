import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:treehacks2021/components/standard_button.dart';
import 'package:treehacks2021/main.dart';
import 'package:treehacks2021/screens/challenges_screens/challenges_screen.dart';
import 'package:treehacks2021/screens/profile_screen.dart';
import 'package:treehacks2021/screens/group_screens/groups.dart';
import 'package:treehacks2021/workout_screens/camera_screen.dart';

User loggedInUser;

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  TabController _tabController;
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
    getCurrentUser();
    // TODO: implement initState
  }

  static const tabs = <Tab>[
    Tab(
//      icon: ,
      child: Icon(
        Icons.person,
        color: Color(0xFFA154F2),
        size: 30,
      ),
    ),
    Tab(
      child: Icon(
        Icons.map,
        color: Color(0xFFA154F2),
        size: 30,
      ),
    ),
    Tab(
      child: Icon(
        Icons.view_list,
        color: Color(0xFFA154F2),
        size: 30,
      ),
    ),
  ];

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        //print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

//  void getMessages() async {
//    final messages = await _firestore.collection('messages').getDocuments();
//    for (var message in messages.documents) {
//      print(message.data);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ChallengesScreen(),
          Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              elevation: 10,
              leading: Text(
                "Home",
                style: TextStyle(fontSize: 20),
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.account_circle_outlined),
                    onPressed: () {
                      _auth.signOut();
                      Navigator.pushNamed(context, ProfileScreen.id);
                    }),
              ],
              title: Center(child: Text('')),
              backgroundColor: Colors.lightBlueAccent,
            ),
            body: Column(
              children: [
                Spacer(),
                StandardButton("Start Exercise", () => NavigationUtil.navigate(context, CameraScreen.id)),
                Spacer()
              ],
            ),
          ),
          GroupScreen(),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
    );
  }
}

class Stream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
