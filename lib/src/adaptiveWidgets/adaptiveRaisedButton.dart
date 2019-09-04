import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';



class AdaptiveRaisedButton extends AdaptiveWidget<CupertinoButton, RaisedButton> {

  final String text;
  final Function func;
  final double buttonWidth;
  final Color color;
  final Color textColor;
  final Key key;


  AdaptiveRaisedButton({
    @required this.text,
    @required this.func,
    this.buttonWidth,
    this.color,
    this.textColor,
    this.key
  });

  @override
  RaisedButton buildMaterialWidget(BuildContext context) {
    return RaisedButton(
        color: color,
        textColor: textColor,
        child: SizedBox(
          width: buttonWidth,
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: func

    );
  }

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        color: color,
        child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        onPressed: func
    );
  }

}