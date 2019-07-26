/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/data/config.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/user/user_change_bloc.dart';
import 'package:ox_coi/src/user/user_change_event_state.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';
import 'package:rxdart/rxdart.dart';

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  UserChangeBloc _userChangeBloc = UserChangeBloc();
  Navigation navigation = Navigation();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();

  String _avatar;

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.settingsUser);
    _userChangeBloc.dispatch(RequestUser());
    final userStatesObservable = new Observable<UserChangeState>(_userChangeBloc.state);
    userStatesObservable.listen((state) => _handleUserChangeStateChange(state));
  }

  _handleUserChangeStateChange(UserChangeState state) {
    if (state is UserChangeStateSuccess) {
      Config config = state.config;
      _usernameController.text = config.username;
      _statusController.text = config.status;
      String avatarPath = config.avatarPath;
      if (avatarPath != null && avatarPath.isNotEmpty) {
        _avatar = config.avatarPath;
      }
    } else if (state is UserChangeStateApplied) {
      navigation.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => navigation.pop(context),
          ),
          title: Text(AppLocalizations.of(context).userSettingsTitle),
          actions: <Widget>[IconButton(icon: Icon(Icons.check), onPressed: _saveChanges)],
        ),
        body: buildForm());
  }

  Widget buildForm() {
    return BlocBuilder(
        bloc: _userChangeBloc,
        builder: (context, state) {
          if (state is UserChangeStateSuccess) {
            return buildEditUserDataView(state.config);
          } else if (state is UserChangeStateFailure) {
            return new Text(state.error);
          } else {
            return new Container();
          }
        });
  }

  Widget buildEditUserDataView(Config config) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: editUserAvatarVerticalPadding)),
            Align(
                alignment: Alignment.center,
                child: ProfileData(
                  color: accent,
                  imageActionCallback: _setAvatar,
                  child: ProfileAvatar(
                    imagePath: _avatar,
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(left: listItemPaddingBig, right: listItemPaddingBig),
              child: Column(
                children: <Widget>[
                  TextFormField(
                      maxLines: 1,
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).userSettingsUsernameLabel)),
                  TextFormField(
                    maxLines: 2,
                    controller: _statusController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).userSettingsStatusLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _setAvatar(String avatarPath){
    setState(() {
      _avatar = avatarPath;
    });
  }

  void _saveChanges() async {
    String avatarPath = !isNullOrEmpty(_avatar) ? _avatar : null;
    _userChangeBloc.dispatch(UserPersonalDataChanged(username: _usernameController.text, status: _statusController.text, avatarPath: avatarPath));
  }
}
