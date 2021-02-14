import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'project_colors.dart';
import 'package:gradient_text/gradient_text.dart';

class BubbleList extends StatelessWidget{
  BubbleList({@required this.nameScoreMap});
  final Map<String, int> nameScoreMap;

  @override
  Widget build(BuildContext context) {
    var sortedNames = nameScoreMap.keys.toList(growable:false)
      ..sort((k2, k1) => nameScoreMap[k1].compareTo(nameScoreMap[k2]));

    return CupertinoScrollbar(
      child: ListView.builder(
        itemCount: nameScoreMap.keys.length,
        padding: EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index) => buildBubbleListItem(index: index, entries: nameScoreMap, sortedNames: sortedNames),
      ),
    );
  }

  Widget buildBubbleListItem({int index, Map<String, int> entries, List<String> sortedNames, bool isYou = false}) {
    return Row(children: [
      Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: ProjectColors.colorStandardGradient),
              borderRadius: BorderRadius.all(Radius.circular(500))),
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(500)),
            ),
            child: Center(
                child: GradientText('${index + 1}',
                    gradient: LinearGradient(colors: ProjectColors.colorStandardGradient),
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
          )),
      SizedBox(width: 10),
      Expanded(
          child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(500))),
              child: Row(children: [
                Expanded(
                  // https://stackoverflow.com/questions/44579918/flutter-wrap-text-on-overflow-like-insert-ellipsis-or-fade
                  child: Text(isYou ? 'You' : '${sortedNames[index]}',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Text('${entries[sortedNames[index]]} Points',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
              ]))),
    ]);
  }

}