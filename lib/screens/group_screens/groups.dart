import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:treehacks2021/screens/group_screens/group_scoreboard.dart';
import 'package:treehacks2021/state.dart';
import 'package:treehacks2021/components/clickable_gray_box.dart';

class GroupScreen extends StatelessWidget {
  static String id = "group_screen";
  @override
  Widget build(BuildContext context) {
    List<Group> groups;
    return CupertinoScrollbar(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) => {
          return ClickableGrayBox(title: groups[index].title, line1: groups[index].tags.toString(), line2: groups[index].description, onPressed: Navigator.pushNamed(context, GroupScoreboard.id), buttonText: "More");
        },
      ),
    );
  }
}