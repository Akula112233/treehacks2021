import 'package:flutter/material.dart';
import 'standard_button.dart';

class ClickableGrayBox extends StatelessWidget{
  ClickableGrayBox({@required this.title, @required this.line1, @required this.onPressed, @required this.buttonText, this.line2 = "", this.challengesDropdown});
  final String title;
  final String line1;
  final String buttonText;
  final String line2;
  final Function onPressed;
  final Function challengesDropdown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          margin: EdgeInsets.only(top: 8.0, bottom: 12.0),
          padding: EdgeInsets.only(left: 20, right: 5, top: 15, bottom: 15),
          decoration: BoxDecoration(
              color: Color(0xff30353B),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white),
                  ),
                  Container(padding: EdgeInsets.only(top: 3)),
                  Text(line1,
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.white)),
                  if(line2.isNotEmpty)
                    Text(line2,
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.white)),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Row(children: [
                        Spacer(),
                        Container(
                            child: StandardButton(
                              buttonText,
                              onPressed,
                              textSize: 13,
                            )),
                      ]))
                ],
              ),
            ],
          )),
    );
  }
}