import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';

class AdaptiveAppBar extends AdaptiveWidget<CupertinoNavigationBar, AppBar> with PreferredSizeWidget {

  final Function func;
  final Color color;
  final Widget title;
  final List<Widget> icons;
  final double elevation;

  AdaptiveAppBar({
    this.func,
    this.color,
    this.title,
    this.icons,
    this.elevation
  });

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar(
      title: title,
      actions: icons,
      elevation: elevation
    );
  }

  @override
  CupertinoNavigationBar buildCupertinoWidget(BuildContext context) {
    return CupertinoNavigationBar(
      actionsForegroundColor: Colors.white,
      middle: title,
      backgroundColor: color,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: icons
      )
    );
  }


  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}