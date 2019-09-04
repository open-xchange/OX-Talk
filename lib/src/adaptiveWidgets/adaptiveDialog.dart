import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';

class AdaptiveDialog extends AdaptiveWidget<CupertinoAlertDialog, AlertDialog> {

  final Widget title;
  final Widget content;
  final List<Widget> actions;

  AdaptiveDialog({
    this.title,
    this.content,
    this.actions
  });

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions
    );
  }

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
        actions: actions
    );
  }

}