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
import 'package:ox_coi/src/chat/chat_change_bloc.dart';
import 'package:ox_coi/src/chat/chat_change_event_state.dart';
import 'package:ox_coi/src/chat/chat_profile_group_contact_item.dart';
import 'package:ox_coi/src/contact/contact_list_bloc.dart';
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:ox_coi/src/widgets/profile_body.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';

class ChatProfileGroup extends StatefulWidget {
  final int chatId;
  final String chatName;
  final Color chatColor;
  final bool isVerified;

  ChatProfileGroup({@required this.chatId, @required this.chatName, @required this.chatColor, @required this.isVerified});

  @override
  _ChatProfileGroupState createState() => _ChatProfileGroupState();
}

class _ChatProfileGroupState extends State<ChatProfileGroup> {
  ContactListBloc _contactListBloc = ContactListBloc();

  @override
  void initState() {
    super.initState();
    _contactListBloc.dispatch(RequestContacts(listTypeOrChatId: widget.chatId));
  }

  @override
  void dispose() {
    _contactListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          var appLocalizations = AppLocalizations.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ProfileHeader(
                dynamicChildren: [
                  ProfileHeaderText(text: widget.chatName),
                  ProfileHeaderText(
                    text: appLocalizations.chatProfileGroupMemberCounter(state.contactIds.length),
                    iconData: widget.isVerified ? Icons.verified_user : null,
                  )
                ],
                color: widget.chatColor,
                initialsString: Avatar.getInitials(widget.chatName),
              ),
              ProfileActionList(tiles: [
                ProfileAction(
                  iconData: Icons.delete,
                  text: appLocalizations.chatProfileLeaveGroupButtonText,
                  onTap: () => showActionDialog(context, ProfileActionType.leave, _leaveGroup),
                ),
              ]),
              Divider(height: dividerHeight),
              _buildGroupMemberList(state)
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  ListView _buildGroupMemberList(ContactListStateSuccess state) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: listItemPadding),
        itemCount: state.contactIds.length,
        itemBuilder: (BuildContext context, int index) {
          var contactId = state.contactIds[index];
          var key = "$contactId-${state.contactLastUpdateValues[index]}";
          return ChatProfileGroupContactItem(contactId: contactId, key: key);
        });
  }

  _leaveGroup() async {
    ChatChangeBloc chatChangeBloc = ChatChangeBloc();
    chatChangeBloc.dispatch(LeaveGroupChat(chatId: widget.chatId));
    chatChangeBloc.dispatch(DeleteChat(chatId: widget.chatId));
    Navigation navigation = Navigation();
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }
}
