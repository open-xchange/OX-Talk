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
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:ox_coi/src/chatlist/chat_list_event_state.dart';
import 'package:ox_coi/src/data/chat_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/message/message_list_bloc.dart';
import 'package:ox_coi/src/message/message_list_event_state.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:ox_coi/src/utils/text.dart';
import 'package:rxdart/rxdart.dart';

import 'chat_list.dart' as ChatListWidget;

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  final Repository<ChatMsg> _messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
  final _messageListBloc = MessageListBloc();
  RepositoryMultiEventStreamHandler _repositoryStreamHandler;
  String _currentSearch;
  bool _showInvites;

  @override
  ChatListState get initialState => ChatListStateInitial();

  @override
  Stream<ChatListState> mapEventToState(ChatListEvent event) async* {
    if (event is RequestChatList) {
      _currentSearch = null;
      yield ChatListStateLoading();
      try {
        setupChatListListener();
        bool antiMobbingActivated = await getPreference(preferenceAntiMobbing);
        _showInvites = antiMobbingActivated == null || !antiMobbingActivated;
        if (_showInvites) {
          setupInvites();
        } else {
          setupChatList(true);
        }
      } catch (error) {
        yield ChatListStateFailure(error: error.toString());
      }
    } else if (event is SearchChatList) {
      try {
        _currentSearch = event.query;
        setupChatList(true);
      } catch (error) {
        yield ChatListStateFailure(error: error.toString());
      }
    } else if (event is InvitesPrepared) {
      setupChatList(true, event.messageIds);
    } else if (event is ChatListModified) {
      yield ChatListStateSuccess(
        chatListItemWrapper: event.chatListItemWrapper,
      );
    }
  }

  @override
  Stream<ChatListState> transform(Stream<ChatListEvent> events, Stream<ChatListState> Function(ChatListEvent event) next) {
    return super.transform(
      (events as Observable<ChatListEvent>).debounceTime(
        Duration(milliseconds: 300),
      ),
      next,
    );
  }

  @override
  void dispose() {
    _chatRepository.removeListener(_repositoryStreamHandler);
    _repositoryStreamHandler?.tearDown();
    _messageListBloc.dispose();
    super.dispose();
  }

  void setupChatListListener() {
    if (_repositoryStreamHandler == null) {
      _repositoryStreamHandler =
          RepositoryMultiEventStreamHandler(Type.publish, [Event.chatModified, Event.incomingMsg, Event.msgsChanged], _onChatListChanged);
      _chatRepository.addListener(_repositoryStreamHandler);

      final messageListObservable = Observable<MessageListState>(_messageListBloc.state);
      messageListObservable.listen((state) async {
        if (state is MessagesStateSuccess) {
          var uniqueInviteMap = LinkedHashMap<int, int>();
          Context context = Context();
          List<int> contacts = await context.getContacts(2, null);
          await Future.forEach(state.messageIds, (messageId) async {
            ChatMsg message = _messageListRepository.get(messageId);
            var contactId = await message.getFromId();
            if (!uniqueInviteMap.containsKey(contactId)) {
              uniqueInviteMap.putIfAbsent(contactId, () => messageId);
            }
          });
          List<int> removedContacts = List<int>();
          await Future.forEach(uniqueInviteMap.keys, (contactId) async{
            if(contacts.contains(contactId)){
              int newChatId = await context.createChatByMessageId(uniqueInviteMap[contactId]);
              _messageListRepository.clear();
              _chatRepository.putIfAbsent(id: newChatId);
              removedContacts.add(contactId);
            }
          });
          for(int contactId in removedContacts){
            uniqueInviteMap.remove(contactId);
          }
          dispatch(InvitesPrepared(messageIds: uniqueInviteMap.values.toList(growable: false)));
        }
      });
    }
  }

  Future<void> _onChatListChanged(event) async {
    if (_showInvites) {
      setupInvites();
    } else {
      dispatch(ChatListModified(
        chatListItemWrapper: createChatListItemWrapper(_chatRepository.getAllIds(), _chatRepository.getAllLastUpdateValues()),
      ));
    }
  }

  Future setupInvites() async {
    _messageListBloc.dispatch(RequestMessages(chatId: Chat.typeInvite));
  }

  ChatListItemWrapper createChatListItemWrapper(List<int> ids, List<int> lastUpdateValues, [List<int> types]) {
    var typesFallback = List<ChatListWidget.ChatListItemType>.filled(ids.length, ChatListWidget.ChatListItemType.chat, growable: false);
    return ChatListItemWrapper(
      ids: ids,
      types: types ?? typesFallback,
      lastUpdateValues: lastUpdateValues,
    );
  }

  Future<ChatListItemWrapper> mergeInvitesAndChats(List<int> chatIds, List<int> inviteMessageIds) async {
    var ids = List<int>();
    var types = List<ChatListWidget.ChatListItemType>();
    var lastUpdateValues = List<int>();
    int stop = chatIds.length + inviteMessageIds.length;
    int index = 0;
    int nextChat = 0;
    int nextInvite = 0;
    while (index < stop) {
      if (nextChat >= chatIds.length) {
        nextInvite = addInviteMessageToResult(ids, getMessage(inviteMessageIds, nextInvite), types, lastUpdateValues, nextInvite);
      } else if (nextInvite >= inviteMessageIds.length) {
        nextChat = addChatToResult(ids, getChat(chatIds, nextChat), types, lastUpdateValues, nextChat);
      } else {
        Chat chat = getChat(chatIds, nextChat);
        ChatSummary chatSummary = chat.get(ChatExtension.chatSummary);
        var chatTimestamp = chatSummary.timestamp;
        ChatMsg message = getMessage(inviteMessageIds, nextInvite);
        var inviteTimestamp = await message.getTimestamp();
        if (chatTimestamp > inviteTimestamp) {
          nextChat = addChatToResult(ids, chat, types, lastUpdateValues, nextChat);
        } else {
          nextInvite = addInviteMessageToResult(ids, message, types, lastUpdateValues, nextInvite);
        }
      }
      index++;
    }
    return ChatListItemWrapper(
      ids: ids,
      types: types,
      lastUpdateValues: lastUpdateValues,
    );
  }

  Chat getChat(List<int> chatIds, int nextChat) => _chatRepository.get(chatIds[nextChat]);

  ChatMsg getMessage(List<int> inviteMessageIds, int nextInvite) => _messageListRepository.get(inviteMessageIds[nextInvite]);

  int addChatToResult(List ids, Chat chat, List types, List lastUpdateValues, int nextChat) {
      ids.add(chat.id);
      types.add(ChatListWidget.ChatListItemType.chat);
      lastUpdateValues.add(chat.lastUpdate);
      nextChat++;
      return nextChat;
  }

  int addInviteMessageToResult(List ids, ChatMsg message, List types, List lastUpdateValues, int nextInvite) {
    ids.add(message.id);
    types.add(ChatListWidget.ChatListItemType.message);
    lastUpdateValues.add(message.lastUpdate);
    nextInvite++;
    return nextInvite;
  }

  Future<void> setupChatList(bool chatListRefreshNeeded, [List<int> inviteMessageIds]) async {
    var ids = List<int>();
    List<int> chatIds = List();
    var lastUpdateValues = List<int>();
    if (chatListRefreshNeeded) {
      var chatList = ChatList();
      await chatList.setup(_currentSearch);
      int chatCount = await chatList.getChatCnt();
      Map<int, dynamic> chatSummaries = Map();
      for (int i = 0; i < chatCount; i++) {
        int chatId = await chatList.getChat(i);
        chatIds.add(chatId);
        var summaryData = await chatList.getChatSummary(i);
        var chatSummary = ChatSummary.fromMethodChannel(summaryData);
        chatSummaries.putIfAbsent(chatId, () => chatSummary);
      }
      await chatList.tearDown();
      _chatRepository.putIfAbsent(ids: chatIds);
      chatSummaries.forEach((id, chatSummary) {
        var summary = _chatRepository.get(id).get(ChatExtension.chatSummary);
        if(summary != chatSummary) {
          _chatRepository.get(id).set(ChatExtension.chatSummary, chatSummary);
        }
      });
    }
    if (isNullOrEmpty(_currentSearch)) {
      ids = _chatRepository.getAllIds();
      lastUpdateValues = _chatRepository.getAllLastUpdateValues();
    } else {
      var chatLastUpdateValues = List<int>();
      int timestamp = getNowTimestamp();
      chatIds.forEach((_) {
        chatLastUpdateValues.add(timestamp);
      });
      ids = chatIds;
      lastUpdateValues = chatLastUpdateValues;
    }
    ChatListItemWrapper chatListItemWrapper;
    if (inviteMessageIds == null || inviteMessageIds.isEmpty) {
      chatListItemWrapper = ChatListItemWrapper(
        ids: ids,
        types: List<ChatListWidget.ChatListItemType>.filled(ids.length, ChatListWidget.ChatListItemType.chat, growable: true),
        lastUpdateValues: lastUpdateValues,
      );
    } else {
      chatListItemWrapper = await mergeInvitesAndChats(ids, inviteMessageIds);
    }
    dispatch(ChatListModified(chatListItemWrapper: chatListItemWrapper));
  }
}
