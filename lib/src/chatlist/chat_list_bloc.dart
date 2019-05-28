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
import 'package:ox_coi/src/chatlist/chat_list_event.dart';
import 'package:ox_coi/src/chatlist/chat_list_state.dart';
import 'package:ox_coi/src/data/chat_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/utils/text.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final Repository<Chat> chatRepository = RepositoryManager.get(RepositoryType.chat);
  RepositoryMultiEventStreamHandler repositoryStreamHandler;

  @override
  ChatListState get initialState => ChatListStateInitial();

  @override
  Stream<ChatListState> mapEventToState(ChatListState currentState, ChatListEvent event) async* {
    if (event is RequestChatList) {
      yield ChatListStateLoading();
      try {
        setupChatListListener();
        setupChatList(event.query);
      } catch (error) {
        yield ChatListStateFailure(error: error.toString());
      }
    } else if (event is ChatListModified) {
      yield ChatListStateSuccess(
        chatIds: chatRepository.getAllIds(),
        chatLastUpdateValues: chatRepository.getAllLastUpdateValues(),
      );
    } else if (event is ChatListSearched) {
      yield ChatListStateSuccess(
        chatIds: event.chatIds,
        chatLastUpdateValues: event.lastUpdateValues,
      );
    }
  }

  @override
  void dispose() {
    chatRepository.removeListener(repositoryStreamHandler);
    super.dispose();
  }

  void setupChatList([String query]) async {
    ChatList chatList = ChatList();
    await chatList.setup(query);
    int chatCount = await chatList.getChatCnt();
    List<int> chatIds = List();
    Map<int, dynamic> chatSummaries = Map();
    for (int i = 0; i < chatCount; i++) {
      int chatId = await chatList.getChat(i);
      chatIds.add(chatId);
      var summaryData = await chatList.getChatSummary(i);
      var chatSummary = ChatSummary.fromMethodChannel(summaryData);
      chatSummaries.putIfAbsent(chatId, () => chatSummary);
    }
    await chatList.tearDown();
    chatRepository.putIfAbsent(ids: chatIds);
    chatSummaries.forEach((id, chatSummary) {
      chatRepository.get(id).set(ChatExtension.chatSummary, chatSummary);
    });
    if (isNullOrEmpty(query)) {
      dispatch(ChatListModified());
    } else {
      dispatch(ChatListSearched(chatIds: chatIds, lastUpdateValues: null));
    }
  }

  void setupChatListListener() {
    if (repositoryStreamHandler == null) {
      repositoryStreamHandler = RepositoryMultiEventStreamHandler(Type.publish, [Event.incomingMsg, Event.msgsChanged], _chatListModified);
      chatRepository.addListener(repositoryStreamHandler);
    }
  }

  _chatListModified() {
    dispatch(ChatListModified());
  }
}
