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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/message/message_list_event.dart';
import 'package:ox_coi/src/message/message_list_state.dart';

class MessageListBloc extends Bloc<MessageListEvent, MessageListState> {
  RepositoryMultiEventStreamHandler repositoryStreamHandler;
  Repository<ChatMsg> _messageListRepository;
  int _chatId;

  @override
  MessageListState get initialState => MessagesStateInitial();

  @override
  Stream<MessageListState> mapEventToState(MessageListState currentState, MessageListEvent event) async* {
    if (event is RequestMessages) {
      yield MessagesStateLoading();
      try {
        _chatId = event.chatId;
        _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, _chatId);
        _setupMessagesListener();
        _setupMessages();
      } catch (error) {
        yield MessagesStateFailure(error: error.toString());
      }
    } else if (event is UpdateMessages) {
      try {
        _setupMessages();
      } catch (error) {
        yield MessagesStateFailure(error: error.toString());
      }
    } else if (event is MessagesLoaded) {
      yield MessagesStateSuccess(
        messageIds: _messageListRepository.getAllIds().reversed.toList(growable: false),
        messageLastUpdateValues: _messageListRepository.getAllLastUpdateValues().reversed.toList(growable: false),
        dateMarkerIds: event.dateMarkerIds,
      );
    }
  }

  @override
  void dispose() {
    _messageListRepository.removeListener(repositoryStreamHandler);
    super.dispose();
  }

  void _setupMessagesListener() async {
    if (repositoryStreamHandler == null) {
      repositoryStreamHandler = RepositoryMultiEventStreamHandler(Type.publish, [Event.incomingMsg, Event.msgsChanged, Event.msgDelivered, Event.msgRead], _updateMessages);
      _messageListRepository.addListener(repositoryStreamHandler);
    }
  }

  void _updateMessages() => dispatch(UpdateMessages());

  void _setupMessages() async {
    List<int> dateMakerIds = List();
    Context context = Context();
    List<int> messageIds = List.from(await context.getChatMessages(_chatId, Context.chatListAddDayMarker));
    for (int index = 0; index < messageIds.length; index++) {
      int previousIndex = index - 1;
      if (previousIndex >= 0 && messageIds[previousIndex] == ChatMsg.idDayMarker) {
        dateMakerIds.add(messageIds[index]);
      }
    }
    messageIds.removeWhere((id) => id == ChatMsg.idDayMarker);
    _messageListRepository.putIfAbsent(ids: messageIds);
    await Future.forEach(messageIds, (id) async {
      ChatMsg message = _messageListRepository.get(id);
      if (await message.isOutgoing()) {
        await message.reloadValue(ChatMsg.methodMessageGetState);
      }
    });
    dispatch(MessagesLoaded(dateMarkerIds: dateMakerIds));
  }

  void submitMessage(String text) async {
    Context context = Context();
    await context.createChatMessage(_chatId, text);
    _updateMessages();
  }

  void submitAttachmentMessage(String path, int fileType, [String text]) async {
    Context _context = Context();
    await _context.createChatAttachmentMessage(_chatId, path, fileType, text);
    dispatch(UpdateMessages());
  }
}
