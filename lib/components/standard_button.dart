import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'project_colors.dart';

class StandardButton extends StatelessWidget{
  StandardButton(this.text, this.onPressed, {this.textSize = 24, this.centralized = false});
  final String text;
  final Function onPressed;
  final double textSize;
  final bool centralized;

  Widget build(BuildContext context) {
    final textCapitalized = text.toUpperCase();
    final Widget actualButton = (Container(
      margin: EdgeInsets.only(top: 10, left: 15, right: 15),
      child: RaisedButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: ProjectColors.colorStandardGradient),
            borderRadius: BorderRadius.all(Radius.circular(80.0)),
          ),
          child: Container(
            constraints: const BoxConstraints(
                minWidth: 100.0,
                minHeight: 40.0), // min sizes for Material buttons
            alignment: Alignment.center,
            child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 25),
              Container(
                child: Text(textCapitalized,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: textSize, color: Colors.white)),
              ),
              Container(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_forward_ios,
                      size: 22, color: Colors.white)),
              SizedBox(width: 10)
            ]),
          ),
        ),
      ),
    ));
    if (centralized) {
      return Row(
        children: [
          Spacer(),
          actualButton,
          Spacer(),
        ],
      );
    } else {
      return actualButton;
    }
  }
}