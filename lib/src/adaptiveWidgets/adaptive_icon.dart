import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_widget.dart';
import 'dart:io';

enum IconDataSet {
  flag,
  phone,
  close,
  check,
  add,
  delete,
  mic,
  camera,
  videocam,
  send,
  search,
  arrowForward,
  importContacts,
  block,
  back,
  contentCopy,
  settings,
  error,
  image,
  videoLibrary,
  pictureAsPdf,
  gif,
  insertDriveFile,
  groupAdd,
  chat,
  mail,
  person,
  personAdd,
  lock,
  photo,
  cameraAlt,
  clear,
  arrowBack,
  group,
  verifiedUser,
  edit,
  reportProblem,
  attachFile,
  done,
  doneAll,
  accountCircle,
  notifications,
  https,
  security,
  info,
  bugReport,
  addAPhoto,
  visibility,
  visibilityOff,
  contacts,
  forward,
  share,
}

class AdaptiveIcon extends AdaptiveWidget<Icon, Icon> {

  final double size;
  final Color color;
  final IconDataSet icon;
  final iconData = {
    // No star icon in CupertinoIcons
    IconDataSet.flag : [Icons.star, Icons.star],
    IconDataSet.phone : [CupertinoIcons.phone_solid, Icons.phone],
    IconDataSet.check : [CupertinoIcons.check_mark, Icons.check],
    IconDataSet.close : [CupertinoIcons.clear_thick, Icons.clear],
    IconDataSet.add : [CupertinoIcons.add, Icons.add],
    IconDataSet.delete : [CupertinoIcons.delete, Icons.delete],
    IconDataSet.mic : [CupertinoIcons.mic, Icons.mic],
    IconDataSet.camera : [CupertinoIcons.photo_camera, Icons.camera_alt],
    IconDataSet.videocam : [CupertinoIcons.video_camera, Icons.videocam],
    IconDataSet.send : [CupertinoIcons.forward, Icons.send],
    IconDataSet.search : [CupertinoIcons.search, Icons.search],
    IconDataSet.arrowForward : [CupertinoIcons.forward, Icons.arrow_forward],
    IconDataSet.importContacts : [CupertinoIcons.person_add_solid, Icons.import_contacts],
    IconDataSet.block : [CupertinoIcons.padlock_solid, Icons.block],
    IconDataSet.back : [CupertinoIcons.back, Icons.arrow_back],
    IconDataSet.contentCopy : [CupertinoIcons.collections, Icons.content_copy],
    IconDataSet.settings : [CupertinoIcons.gear_solid, Icons.settings],
    // No error icon in CupertinoIcons
    IconDataSet.error : [Icons.error, Icons.error],
    // No image icon in CupertinoIcons
    IconDataSet.image : [Icons.image, Icons.image],
    // No video library icon in CupertinoIcons
    IconDataSet.videoLibrary : [Icons.video_library, Icons.video_library],
    // No picture as pdf icon in CupertinoIcons
    IconDataSet.pictureAsPdf : [Icons.picture_as_pdf, Icons.picture_as_pdf],
    // No gif icon in CupertinoIcons
    IconDataSet.gif : [Icons.gif, Icons.gif],
    // No file icon in CupertinoIcons
    IconDataSet.insertDriveFile : [Icons.insert_drive_file, Icons.insert_drive_file],
    IconDataSet.groupAdd : [CupertinoIcons.group_solid, Icons.group_add],
    // No chat icon in CupertinoIcons
    IconDataSet.chat : [Icons.chat, Icons.chat],
    IconDataSet.mail : [CupertinoIcons.mail_solid, Icons.mail],
    IconDataSet.person : [CupertinoIcons.person_solid, Icons.person],
    IconDataSet.personAdd : [CupertinoIcons.person_add_solid, Icons.person_add],
    IconDataSet.lock : [CupertinoIcons.padlock_solid, Icons.lock],
    // No photo icon in CupertinoIcons
    IconDataSet.photo : [Icons.photo, Icons.photo],
    IconDataSet.cameraAlt : [CupertinoIcons.photo_camera_solid, Icons.camera_alt],
    IconDataSet.clear : [CupertinoIcons.clear_thick, Icons.clear],
    IconDataSet.arrowBack : [CupertinoIcons.back, Icons.arrow_back],
    IconDataSet.group : [CupertinoIcons.group_solid, Icons.group],
    // No verified user icon in CupertinoIcons
    IconDataSet.verifiedUser : [Icons.verified_user, Icons.verified_user],
    // No edit icon in CupertinoIcons
    IconDataSet.edit : [Icons.edit, Icons.edit],
    // No report problem icon in CupertinoIcons
    IconDataSet.reportProblem : [Icons.report_problem, Icons.report_problem],
    // No attach file icon in CupertinoIcons
    IconDataSet.attachFile : [Icons.attach_file, Icons.attach_file],
    // No done icon in CupertinoIcons
    IconDataSet.done : [Icons.done, Icons.done],
    // No done all icon in CupertinoIcons
    IconDataSet.done : [Icons.done_all, Icons.done_all],
    // No account circle icon in CupertinoIcons
    IconDataSet.accountCircle : [Icons.account_circle, Icons.account_circle],
    // No notifications icon in CupertinoIcons
    IconDataSet.notifications : [Icons.notifications, Icons.notifications],
    // No https icon in CupertinoIcons
    IconDataSet.https : [Icons.https, Icons.https],
    // No security icon in CupertinoIcons
    IconDataSet.security : [Icons.security, Icons.security],
    IconDataSet.info : [CupertinoIcons.info, Icons.info],
    // No bug report icon in CupertinoIcons
    IconDataSet.bugReport : [Icons.bug_report, Icons.bug_report],
    // No add a photo icon in CupertinoIcons
    IconDataSet.addAPhoto : [Icons.add_a_photo, Icons.add_a_photo],
    // No visibility icon in CupertinoIcons
    IconDataSet.visibility : [Icons.visibility, Icons.visibility],
    // No visibility off icon in CupertinoIcons
    IconDataSet.visibilityOff : [Icons.visibility_off, Icons.visibility_off],
    // No contacts icon in CupertinoIcons
    IconDataSet.contacts : [Icons.contacts, Icons.contacts],
    IconDataSet.forward : [CupertinoIcons.forward, Icons.forward],
    IconDataSet.share : [CupertinoIcons.share, Icons.share],
  };

  AdaptiveIcon({
    Key key,
    this.size,
    this.color,
    @required this.icon,
  }) : super(childKey: key);

  @override
  Icon buildMaterialWidget(BuildContext context) {
    return Icon(
      getIconData(icon),
      size: size,
      color: color,
      key: childKey,
    );
  }

  @override
  Icon buildCupertinoWidget(BuildContext context) {
    print(icon);
    return Icon(
      getIconData(icon),
      size: size,
      color: color,
      key: childKey,
    );
  }

  IconData getIconData(IconDataSet iconDataSet) {
    var icon = iconData[iconDataSet];
    return Platform.isIOS ? icon[0] : icon[1];
  }
}