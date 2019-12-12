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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_app_bar.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon_button.dart';
import 'package:ox_coi/src/contact/contact_change_event_state.dart';
import 'package:ox_coi/src/contact/contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:ox_coi/src/widgets/state_info.dart';

import 'contact_change_bloc.dart';

class ContactBlockedList extends StatefulWidget {
  @override
  _ContactBlockedListState createState() => _ContactBlockedListState();
}

class _ContactBlockedListState extends State<ContactBlockedList> {
  ContactListBloc _contactListBloc = ContactListBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    navigation.current = Navigatable(Type.contactListBlocked);
    _contactListBloc.add(RequestContacts(typeOrChatId: blockedContacts));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AdaptiveAppBar(
          leadingIcon: new AdaptiveIconButton(
            icon: new AdaptiveIcon(
              icon: IconSource.close,
            ),
            key: Key(keyContactBlockedListCloseIconButton),
            onPressed: () => navigation.pop(context),
          ),
          title: Text(L10n.get(L.contactBlocked)),
        ),
        body: buildForm());
  }

  Widget buildForm() {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          if (state.contactIds.length > 0) {
            return buildListViewItems(state.contactIds, state.contactLastUpdateValues);
          } else {
            return EmptyListInfo(
              infoText: L10n.get(L.contactNoBlocked),
              imagePath: "assets/images/empty_blocked_list.png",
            );
          }
        } else if (state is! ContactListStateFailure) {
          return StateInfo(showLoading: true);
        } else {
          return AdaptiveIcon(icon: IconSource.error);
        }
      },
    );
  }

  Widget buildListViewItems(List<int> contactIds, List<int> contactLastUpdateValues) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              height: dividerHeight,
              color: CustomTheme.of(context).onBackground.withOpacity(barely),
            ),
        itemCount: contactIds.length,
        itemBuilder: (BuildContext context, int index) {
          var contactId = contactIds[index];
          var key = "$contactId-${contactLastUpdateValues[index]}";
          return Slidable.builder(
            key: Key(key),
            actionPane: SlidableBehindActionPane(),
            actionExtentRatio: 0.2,
            actionDelegate: SlideActionBuilderDelegate(
                actionCount: 1,
                builder: (context, index, animation, step) {
                  return IconSlideAction(
                    caption: L10n.get(L.unblock),
                    color: CustomTheme.of(context).warning,
                    foregroundColor: CustomTheme.of(context).onWarning,
                    iconWidget: AdaptiveIcon(
                      icon: IconSource.block,
                      color: CustomTheme.of(context).onWarning,
                    ),
                    onTap: () {
                      var state = Slidable.of(context);
                      state.dismiss();
                    },
                  );
                }),
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
              onDismissed: (actionType) {
                _unblockContact(contactId: contactId);
              },
            ),
            child: ContactItem(
              contactId: contactId,
              contactItemType: ContactItemType.blocked,
              key: key,
            ),
          );
        });
  }

  // Slide Actions

  _unblockContact({@required int contactId}) {
    ContactChangeBloc bloc = ContactChangeBloc();
    bloc.add(UnblockContact(id: contactId));
    bloc.close();
  }
}
