import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';
import 'adaptiveIcon.dart';

class AdaptiveIconButton extends AdaptiveWidget<CupertinoButton, IconButton> {

  final AdaptiveIcon icon;
  final Function func;
  final Color color;
  final Key key;

  AdaptiveIconButton({
    this.icon,
    this.func,
    this.color,
    this.key
  });

  @override
  IconButton buildMaterialWidget(BuildContext context) {

    return IconButton(

      icon: icon,
      onPressed: func,
      key: key
    );
  }

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {


    return CupertinoButton(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: icon,
      onPressed: func,
    );
  }

}