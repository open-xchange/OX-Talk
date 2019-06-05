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
import 'package:ox_coi/src/contact/contact_change_bloc.dart';
import 'package:ox_coi/src/contact/contact_change_event_state.dart';
import 'package:ox_coi/src/contact/contact_item_bloc.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/contact/contact_profile_mixin.dart';
import 'package:ox_coi/src/data/contact_repository.dart';
import 'package:ox_coi/src/l10n/localizations.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/utils/colors.dart';
import 'package:ox_coi/src/utils/dialog_builder.dart';
import 'package:ox_coi/src/widgets/avatar.dart';
import 'package:ox_coi/src/widgets/profile_header.dart';

enum ChatProfileViewAction { delete, block }

class ChatProfileOneToOne extends StatefulWidget {
  final int _chatId;
  final int _contactId;
  final bool _isSelfTalk;

  ChatProfileOneToOne(this._chatId, this._isSelfTalk, this._contactId, key) : super(key: Key(key));

  @override
  _ChatProfileOneToOneState createState() => _ChatProfileOneToOneState();
}

class _ChatProfileOneToOneState extends State<ChatProfileOneToOne> with ContactProfileMixin {
  ContactItemBloc _contactItemBloc = ContactItemBloc();
  Navigation navigation = Navigation();

  @override
  void initState() {
    super.initState();
    _contactItemBloc.dispatch(RequestContact(contactId: widget._contactId, listType: ContactRepository.validContacts));
  }

  @override
  void dispose() {
    _contactItemBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _contactItemBloc,
        builder: (context, state) {
          if (state is ContactItemStateSuccess) {
            return _buildSingleProfileInfo(state.name, state.email, state.color, state.isVerified);
          } else {
            return Container();
          }
        });
  }

  Widget _buildSingleProfileInfo(String chatName, String email, Color color, bool isVerified) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ProfileHeader(
          dynamicChildren: [
            buildHeaderText(context, chatName, isVerified ? Icons.verified_user : null),
            buildCopyableText(context, email, AppLocalizations.of(context).chatProfileClipboardToastMessage),
          ],
          color: color,
          initialsString: Avatar.getInitials(chatName, email),
        ),
        buildActionList(context, [
          if (!widget._isSelfTalk)
            ListTile(
              leading: Icon(
                Icons.block,
                color: accent,
              ),
              title: Text(
                AppLocalizations.of(context).chatProfileBlockContactButtonText,
              ),
              onTap: () => _showBlockContactDialog(ChatProfileViewAction.block),
            ),
          ListTile(
            leading: Icon(
              Icons.delete,
              color: accent,
            ),
            title: Text(
              AppLocalizations.of(context).chatProfileDeleteChatButtonText,
            ),
            onTap: () => _showBlockContactDialog(ChatProfileViewAction.delete),
          ),
        ]),
      ],
    );
  }

  _showBlockContactDialog(ChatProfileViewAction action) {
    String title;
    String content;
    String positiveButtonText;
    Function positiveAction;
    Type type;

    switch (action) {
      case ChatProfileViewAction.block:
        title = AppLocalizations.of(context).block;
        content = AppLocalizations.of(context).chatProfileBlockContactInfoText;
        positiveButtonText = AppLocalizations.of(context).chatProfileBlockContactButtonText;
        positiveAction = () => _blockContact();
        type = Type.contactBlockDialog;
        break;
      case ChatProfileViewAction.delete:
        title = AppLocalizations.of(context).delete;
        content = AppLocalizations.of(context).chatProfileDeleteChatInfoText;
        positiveButtonText = AppLocalizations.of(context).chatProfileDeleteChatButtonText;
        positiveAction = () => _deleteChat();
        type = Type.chatDeleteDialog;
        break;
    }

    return showConfirmationDialog(
      context: context,
      title: title,
      content: content,
      positiveButton: positiveButtonText,
      positiveAction: positiveAction,
      selfClose: false,
      navigatable: Navigatable(type),
    );
  }

  _blockContact() {
    ContactChangeBloc contactChangeBloc = ContactChangeBloc();
    contactChangeBloc.dispatch(BlockContact(widget._contactId, widget._chatId));
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }

  _deleteChat() {
    ChatChangeBloc chatChangeBloc = ChatChangeBloc();
    chatChangeBloc.dispatch(DeleteChat(chatId: widget._chatId));
    navigation.popUntil(context, ModalRoute.withName(Navigation.root));
  }
}
