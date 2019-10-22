import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';

class AdaptiveAppBar extends AdaptiveWidget<CupertinoNavigationBar, AppBar> with PreferredSizeWidget {
  final Function onPressed;
  final Color color;
  final Widget title;
  final List<Widget> actions;
  final double elevation;
  final Widget leadingIcon;

  AdaptiveAppBar({
    Key key,
    this.onPressed,
    this.color,
    this.title,
    this.actions,
    this.elevation,
    this.leadingIcon,
  }) : super(key: key);

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar(
      key: key,
      leading: leadingIcon,
      title: title,
      actions: actions,
      elevation: elevation,
    );
  }

  @override
  CupertinoNavigationBar buildCupertinoWidget(BuildContext context) {
    return CupertinoNavigationBar(
      key: key,
      leading: leadingIcon,
      middle: title,
      backgroundColor: color,
      trailing: actions != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
