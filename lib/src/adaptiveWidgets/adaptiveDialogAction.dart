import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';

class AdaptiveDialogAction extends AdaptiveWidget<CupertinoDialogAction, FlatButton> {

  final Widget child;
  final Key key;
  final Function func;

  AdaptiveDialogAction({
    this.child,
    this.key,
    this.func
  });

  @override
  FlatButton buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      key: key,
      onPressed: func,
    );
  }

  @override
  CupertinoDialogAction buildCupertinoWidget(BuildContext context) {
    // TODO : Parameter 'key' is missing: https://github.com/flutter/flutter/issues/42729
    return CupertinoDialogAction(
      child: child,
      onPressed: func,
    );
  }

}