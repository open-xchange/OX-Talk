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
import 'package:ox_coi/src/contact/contact_list_event_state.dart';
import 'package:ox_coi/src/contact/contacts_updater_mixin.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/data/repository_stream_handler.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';
import 'package:ox_coi/src/utils/key_generator.dart';

class ContactListBloc extends Bloc<ContactListEvent, ContactListState> with ContactsUpdaterMixin {
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  RepositoryMultiEventStreamHandler _repositoryStreamHandler;
  int _typeOrChatId;
  List<int> _contactsSelected = List();
  String _currentSearch;
  bool _listenersRegistered = false;

  int get contactsSelectedCount => _contactsSelected.length;

  List<int> get contactsSelected => _contactsSelected;

  @override
  ContactListState get initialState => ContactListStateInitial();

  @override
  Stream<ContactListState> mapEventToState(ContactListEvent event) async* {
    if (event is RequestContacts) {
      yield ContactListStateLoading();
      try {
        _currentSearch = null;
        _typeOrChatId = event.typeOrChatId;
        _registerListeners();
        yield* _setupContacts(chatId: event.chatId);
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is SearchContacts) {
      try {
        _currentSearch = event.query;
        yield* _searchContacts();
      } catch (error) {
        yield ContactListStateFailure(error: error.toString());
      }
    } else if (event is ContactsChanged) {
      yield ContactListStateSuccess(
        contactElements: event.ids,
        contactsSelected: _contactsSelected,
      );
    } else if (event is ContactsSearched) {
      yield ContactListStateSuccess(
        contactElements: event.ids,
        contactsSelected: _contactsSelected,
      );
    } else if (event is ContactsSelectionChanged) {
      yield* _selectionChanged(event.id);
    }
  }

  @override
  Future<void> close() {
    _unregisterListeners();
    return super.close();
  }

  void _registerListeners() {
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _repositoryStreamHandler = RepositoryMultiEventStreamHandler(Type.publish, [Event.contactsChanged, Event.chatModified], _onContactsChanged);
      _contactRepository.addListener(_repositoryStreamHandler);
    }
  }

  void _unregisterListeners() {
    if (_listenersRegistered) {
      _listenersRegistered = false;
      _contactRepository.removeListener(_repositoryStreamHandler);
    }
  }

  void _onContactsChanged([event]) async {
    List<int> ids = await getIds(_typeOrChatId);
    final contactHeaderList = await _mergeHeaderAndContacts(contactIds: ids);

    add(ContactsChanged(ids: contactHeaderList));
  }

  Stream<ContactListStateSuccess> _setupContacts({int chatId}) async* {
    List<int> contactIds = await getIds(_typeOrChatId);
    _contactRepository.update(ids: contactIds);
    var contactExtensionProvider = ContactExtensionProvider();
    await Future.forEach(contactIds, (contactId) async {
      var contactExtension = await contactExtensionProvider.get(contactId: contactId);
      if (contactExtension != null) {
        _contactRepository.get(contactId).set(ContactExtension.contactPhoneNumber, contactExtension.phoneNumbers);
        _contactRepository.get(contactId).set(ContactExtension.contactAvatar, contactExtension.avatar);
      }
    });

    final contactHeaderList = await _mergeHeaderAndContacts(contactIds: contactIds, chatId: chatId);

    yield ContactListStateSuccess(
      contactElements: contactHeaderList,
      contactsSelected: _contactsSelected,
    );
  }

  Future<List<dynamic>> _mergeHeaderAndContacts({List<int> contactIds, int chatId}) async {
    final headerList = List();
    final context = Context();
    List<int> chatParticipants;

    if (chatId != null) {
      chatParticipants = await context.getChatContacts(chatId);
    }

    contactIds.forEach((id) async {
      if(chatParticipants != null && chatParticipants.contains(id)){
        return;
      }
      final Contact contact = _contactRepository.get(id);
      final String name = await contact.getName();
      final String email = await contact.getAddress();
      final int lastUpdate = contact.lastUpdate;
      final index = contactIds.indexOf(id);
      final previousContactId = (index > 0) ? contactIds[index - 1] : null;

      String headerText = name.isNullOrEmpty() ? email.getFirstCharacter()?.toUpperCase() : name.getFirstCharacter()?.toUpperCase();
      if (Contact.idSelf == id) {
        headerText = L10n.get(L.contactOwnCardGroupHeaderText);
      }

      if (previousContactId != null) {
        String previousName = await _contactRepository.get(previousContactId).getName();
        if (previousName.isNullOrEmpty()) {
          previousName = await _contactRepository.get(previousContactId).getAddress();
        }

        if (headerText == previousName.getFirstCharacter()?.toUpperCase()) {
          headerList.add(createKeyFromId(id, [lastUpdate]));
        } else {
          headerList.add(headerText);
          headerList.add(createKeyFromId(id, [lastUpdate]));
        }
      } else {
        headerList.add(headerText);
        headerList.add(createKeyFromId(id, [lastUpdate]));
      }
    });

    return headerList;
  }

  Stream<ContactListStateSuccess> _searchContacts() async* {
    Context context = Context();
    List<int> contactIds = List.from(await context.getContacts(2, _currentSearch));
    final contactHeaderList = await _mergeHeaderAndContacts(contactIds: contactIds);

    yield ContactListStateSuccess(
      contactElements: contactHeaderList,
      contactsSelected: _contactsSelected,
    );
  }

  Stream<ContactListStateSuccess> _selectionChanged(int id) async* {
    if (_contactsSelected.contains(id)) {
      _contactsSelected.remove(id);
    } else {
      _contactsSelected.add(id);
    }
    if (_currentSearch.isNullOrEmpty()) {
      _onContactsChanged();
    } else {
      yield* _searchContacts();
    }
  }
}
