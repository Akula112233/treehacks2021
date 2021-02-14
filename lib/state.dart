import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;

class Api {
  static final FirebaseFirestore fire = FirebaseFirestore.instance;

}

Widget buildMyStandardFutureBuilder<T>(
    {@required Future<T> api,
      @required Widget Function(BuildContext, T) child}) {
  return FutureBuilder<T>(
      future: api,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return buildMyStandardLoader();
        } else if (snapshot.hasError)
          return buildMyStandardError(snapshot.error);
        else
          return child(context, snapshot.data);
      });
}

Widget buildMyStandardLoader() {
  print('Built loader');
  return Center(
      child: Container(
          padding: EdgeInsets.only(top: 30),
          child: CircularProgressIndicator()));
}

Widget buildMyStandardError(Object error) {
  return Center(child: Text('Error: $error', style: TextStyle(fontSize: 36)));
}

class Group {
  String groupId;
  String title;
  String description;
  bool isPrivate;
  List<String> tags;
  List<String> users;
  List<String> minigames;
  String groupOwner;
}

class Minigame {
  String title;
  String minigameId;
  String description;
  Map<String, int> userScores;
  Map<String, int> exerciseProgress;
  Map<String, int> exerciseGoals;
  bool isComplete;
}

class Tournament {
  String tournamentId;
  DateTime startDate;
  DateTime endDate;
}