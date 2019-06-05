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
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/colors.dart';

enum SettingsType {
  account,
  security,
  about,
  chat,
}

class SettingsView extends StatelessWidget {
  final Navigation navigation = Navigation();

  SettingsView() {
    navigation.current = Navigatable(Type.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settings),
        ),
        body: buildPreferenceList(context));
  }

  ListView buildPreferenceList(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          leading: Icon(
            Icons.account_circle,
            color: accent,
          ),
          title: Text(AppLocalizations.of(context).accountSettingsTitle),
          onTap: () => _onPressed(context, SettingsType.account),
        ),
        ListTile(
          leading: Icon(
            Icons.security,
            color: accent,
          ),
          title: Text(AppLocalizations.of(context).security),
          onTap: () => _onPressed(context, SettingsType.security),
        ),
        ListTile(
          leading: Icon(
            Icons.chat,
            color: accent,
          ),
          title: Text(AppLocalizations.of(context).chat),
          onTap: () => _onPressed(context, SettingsType.chat),
        ),
        ListTile(
          leading: Icon(
            Icons.info,
            color: accent,
          ),
          title: Text(AppLocalizations.of(context).about),
          onTap: () => _onPressed(context, SettingsType.about),
        ),
      ]).toList(),
    );
  }

  void _onPressed(BuildContext context, SettingsType type) {
    switch (type) {
      case SettingsType.account:
        navigation.pushNamed(context, Navigation.settingsAccount);
        break;
      case SettingsType.security:
        navigation.pushNamed(context, Navigation.settingsSecurity);
        break;
      case SettingsType.about:
        navigation.pushNamed(context, Navigation.settingsAbout);
        break;
      case SettingsType.chat:
        navigation.pushNamed(context, Navigation.settingsChat);
        break;
    }
  }
}
