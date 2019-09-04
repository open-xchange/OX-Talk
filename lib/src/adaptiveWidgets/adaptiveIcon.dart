import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptiveWidget.dart';

class AdaptiveIcon extends AdaptiveWidget<Icon, Icon> {

  final IconData androidIcon;
  final IconData iosIcon;

  AdaptiveIcon({
    this.androidIcon,
    this.iosIcon
  });

  @override
  Icon buildMaterialWidget(BuildContext context) {
    return Icon(androidIcon);
  }

  @override
  Icon buildCupertinoWidget(BuildContext context) {
    return Icon(iosIcon);
  }

}
