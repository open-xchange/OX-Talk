import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';

class AdaptiveInkWell extends AdaptiveWidget<GestureDetector, InkWell> {

  final Function func;
  final Widget child;

  AdaptiveInkWell({
    this.func,
    this.child
  });

  @override
  InkWell buildMaterialWidget(BuildContext context) {
    return InkWell(
      onTap: func,
      child: child
    );
  }

  @override
  GestureDetector buildCupertinoWidget(BuildContext context) {
    return GestureDetector(
        onTap: func,
        child: child
    );
  }

}
