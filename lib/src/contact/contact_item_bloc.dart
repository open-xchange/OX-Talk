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
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart' as SystemContacts;
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:ox_coi/src/contact/contact_item_event_state.dart';
import 'package:ox_coi/src/data/contact_extension.dart';
import 'package:ox_coi/src/data/repository.dart';
import 'package:ox_coi/src/data/repository_manager.dart';
import 'package:ox_coi/src/extensions/color_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/invite/invite_mixin.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contact_change.dart';

enum ContactChangeType {
  add,
  edit,
  delete,
  block,
  unblock,
}

class ContactItemBloc extends Bloc<ContactItemEvent, ContactItemState> with InviteMixin {
  final Repository<Chat> _chatRepository = RepositoryManager.get(RepositoryType.chat);
  Repository<Contact> _contactRepository = RepositoryManager.get(RepositoryType.contact);
  Iterable<SystemContacts.Contact> _systemContacts;
  String _coreContacts = "";
  Map<String, String> _phoneNumbers = Map();

  ContactItemBloc();

  @override
  ContactItemState get initialState => ContactItemStateInitial();

  @override
  Stream<ContactItemState> mapEventToState(ContactItemEvent event) async* {
    try {
      if (event is RequestContact) {
        yield ContactItemStateLoading();
        yield* _setupContact(contactId: event.id, previousContactId: event.previousContactId);
      } else if (event is ChangeContact) {
        yield* _changeContact(event.name, event.email, event.contactAction);
      } else if (event is AddGoogleContact) {
        yield* _addGoogleContact(event.name, event.email, event.changeEmail);
      } else if (event is DeleteContact) {
        yield* _deleteContact(event.id);
      } else if (event is BlockContact) {
        yield* _blockContact(event.id, event.chatId, event.messageId);
      } else if (event is UnblockContact) {
        yield* _unblockContact(event.id);
      } else if (event is MarkContactsAsInitiallyLoaded) {
        await _markContactsAsInitiallyLoadedAsync();
      } else if (event is PerformImport) {
        _systemContacts = await _loadSystemContactsAsync();
        if(_systemContacts == null){
          yield ContactsImportFailure();
        }else {
          yield ContactItemStateLoading();
          yield* _importSystemContacts();
        }
      } else if(event is ImportGooglemailContacts){
        yield* _addUpdateContactsAsync(changeEmails: event.changeEmails);
      }
    } catch (error) {
      yield ContactItemStateFailure(error: error.toString());
    }
  }

  Stream<ContactItemState> _setupContact({@required int contactId, @required int previousContactId}) async* {
    final Contact contact = _contactRepository.get(contactId);
    final String name = await contact.getName();
    final String email = await contact.getAddress();
    final int colorValue = await contact.getColor();
    final bool isVerified = await contact.isVerified();
    final String phoneNumbers = contact.get(ContactExtension.contactPhoneNumber);
    final Color color = colorFromArgb(colorValue);

    String imagePath;
    if (Contact.idSelf == contact.id) {
      imagePath = await contact.getProfileImage();
    } else {
      imagePath = contact.get(ContactExtension.contactAvatar);
    }

    final contactStateData = ContactStateData(
        id: contactId,
        name: name,
        email: email,
        color: color,
        isVerified: isVerified,
        imagePath: imagePath,
        phoneNumbers: phoneNumbers);

    yield ContactItemStateSuccess(contactStateData: contactStateData);
  }

  Stream<ContactItemState> _changeContact(String name, String email, ContactAction contactAction) async* {
    Context context = Context();
    if (contactAction == ContactAction.add) {
      var contactIdByAddress = await context.getContactIdByAddress(email);
      if (contactIdByAddress != 0) {
        yield ContactItemStateFailure(error: contactAddGeneric, id: contactIdByAddress);
        return;
      }
    }
    if (email.contains(googlemailDomain)) {
      yield GoogleContactDetected(name: name, email: email);
    } else {
      if (contactAction == ContactAction.add) {
        int id = await context.createContact(name, email);
        final contactStateData = ContactStateData(id: id, name: name, email: email);
        yield ContactItemStateSuccess(contactStateData: contactStateData, type: ContactChangeType.add, contactHasChanged: true);
      } else {
        int contactId = await context.getContactIdByAddress(email);
        int chatId = await context.getChatByContactId(contactId);
        if (chatId != 0) {
          _renameChat(chatId, name);
        }
        await context.createContact(name, email);
        Contact contact = _contactRepository.get(contactId);
        contact.set(Contact.methodContactGetName, name);
        final contactStateData = (state as ContactItemStateSuccess).contactStateData.copyWith(name: name);
        yield ContactItemStateSuccess(contactStateData: contactStateData, type: ContactChangeType.edit, contactHasChanged: true);
      }
    }
  }

  void _renameChat(int chatId, String name) {
    Chat chat = _chatRepository.get(chatId);
    chat.set(Chat.methodChatGetName, name);
  }

  Stream<ContactItemState> _deleteContact(int id) async* {
    final context = Context();
    final chatId = await context.getChatByContactId(id);
    final wasDeleted = await context.deleteContact(id);
    if (wasDeleted) {
      _contactRepository.remove(id: id);
      await _deleteEmptyChat(chatId);
      yield ContactItemStateSuccess(contactStateData: null, type: ContactChangeType.delete, contactHasChanged: true);
    } else {
      String error = chatId != 0 ? contactDeleteChatExists : contactDeleteGeneric;
      yield ContactItemStateFailure(id: id, error: error);
    }
  }

  Future<void> _deleteEmptyChat(int chatId) async {
    if (chatId != 0) {
      _chatRepository.remove(id: chatId);
      final context = Context();
      await context.deleteChat(chatId);
    }
  }

  Stream<ContactItemState> _blockContact(int contactId, int chatId, int messageId) async* {
    if (contactId == null && messageId != null) {
      contactId = await getContactIdFromMessage(messageId);
    }
    Context context = Context();
    if (chatId == null) {
      chatId = await context.getChatByContactId(contactId);
    }
    await context.blockContact(contactId);
    if (isInviteChat(chatId)) {
      Repository<ChatMsg> messageListRepository = RepositoryManager.get(RepositoryType.chatMessage, Chat.typeInvite);
      messageListRepository.clear();
    }
    adjustChatListOnBlockUnblock(chatId, block: true);
    yield ContactItemStateSuccess(contactStateData: ContactStateData(id: contactId), type: ContactChangeType.block, contactHasChanged: true);
  }

  void adjustChatListOnBlockUnblock(int chatId, {bool block}) {
    if (block) {
      if (chatId != null && chatId != Chat.typeInvite) {
        _chatRepository.remove(id: chatId);
      }
    } else {
      if (chatId != 0) {
        _chatRepository.putIfAbsent(id: chatId);
      }
    }
  }

  Stream<ContactItemState> _unblockContact(int id) async* {
    var contact = _contactRepository.get(id);
    Context context = Context();
    await context.unblockContact(id);
    var email = await contact.getAddress();
    var contactId = await context.getContactIdByAddress(email);
    if (contactId == 0) {
      var name = await contact.getName();
      await context.createContact(name, email);
    }
    var chatId = await context.getChatByContactId(id);
    adjustChatListOnBlockUnblock(chatId, block: false);
    yield ContactItemStateSuccess(contactStateData: ContactStateData(id: contactId), type: ContactChangeType.unblock, contactHasChanged: true);
  }

  Stream<ContactItemState> _addGoogleContact(String name, String email, bool changeEmail) async* {
    Context context = Context();
    if (changeEmail) {
      email = email.replaceAll(googlemailDomain, gmailDomain);
    }

    int id = await context.createContact(name, email);
    final contactStateData = ContactStateData(id: id, name: name, email: email);
    yield ContactItemStateSuccess(contactStateData: contactStateData, type: ContactChangeType.add, contactHasChanged: true);
  }

  Future<bool> isInitialContactsOpeningAsync() async {
    bool systemContactImportShown = await getPreference(preferenceSystemContactsImportShown);
    return systemContactImportShown == null || !systemContactImportShown;
  }

  Future<void> _markContactsAsInitiallyLoadedAsync() async {
    await setPreference(preferenceSystemContactsImportShown, true);
  }

  Future<Iterable<SystemContacts.Contact>> _loadSystemContactsAsync() async {
    bool hasContactPermission = await Permission.contacts.request().isGranted;
    if (hasContactPermission) {
      return await SystemContacts.ContactsService.getContacts();
    } else {
      return null;
    }
  }

  Stream<ContactItemState> _importSystemContacts() async* {
    bool googlemailDetected = false;

    _systemContacts.forEach((contact) {
      if (contact.emails.length != 0) {
        contact.emails.forEach((email) {
          if (email.value.isEmail) {
            if (!googlemailDetected) {
              googlemailDetected = email.value.contains(googlemailDomain);
            }
            _coreContacts += getFormattedContactData(contact, email);
            updatePhoneNumbers(_phoneNumbers, contact, email);
          }
        });
      }
    });

    if (googlemailDetected) {
      yield GooglemailContactsDetected();
    } else {
      yield* _addUpdateContactsAsync(changeEmails: false);
    }
  }

  Stream<ContactItemState> _addUpdateContactsAsync({@required bool changeEmails}) async* {
    final context = Context();
    if (changeEmails) {
      _coreContacts = _coreContacts.replaceAll(googlemailDomain, gmailDomain);
    }
    await updateContacts(_coreContacts, context);

    if (_phoneNumbers.isNotEmpty) {
      List<int> ids = List.from(await context.getContacts(2, null));
      await updateContactExtensions(ids, _phoneNumbers);
    }

    await Future.forEach(_contactRepository.getAll(), (contact) async {
      await updateAvatar(_systemContacts, contact);
      await reloadChatName(context, contact.id);
    });

    _contactRepository.clear();
    _systemContacts = null;
    _phoneNumbers.clear();

    yield ContactsImportSuccess();
  }

  Future<void> reloadChatName(Context context, int contactId) async {
    int chatId = await context.getChatByContactId(contactId);
    if (chatId != 0) {
      Chat chat = _chatRepository.get(chatId);
      chat.reloadValue(Chat.methodChatGetName);
    }
  }

  String getFormattedContactData(SystemContacts.Contact contact, SystemContacts.Item email) {
    return "${contact.displayName}\n${email.value}\n";
  }

  void updatePhoneNumbers(Map<String, String> phoneNumbers, SystemContacts.Contact contact, SystemContacts.Item email) {
    if (contact.phones.isNotEmpty) {
      contact.phones.forEach((phoneNumber) {
        var currentPhoneNumber = phoneNumbers[email.value];
        if (currentPhoneNumber == null) {
          phoneNumbers[email.value] = "";
        }
        phoneNumbers[email.value] += "${phoneNumber.value}\n";
      });
    }
  }

  Future<void> updateAvatar(Iterable<SystemContacts.Contact> systemContacts, Contact contact) async {
    final avatarPath = await _avatarPathAsync();
    final contactEmail = await contact.getAddress();
    final contactExtensionProvider = ContactExtensionProvider();
    final contactId = contact.id;

    systemContacts.forEach((systemContact) {
      systemContact.emails.forEach((email) async {
        if (email.value.isEmail && contactEmail == email.value) {
          String filePath = "";
          // ignore: null_aware_before_operator
          if (systemContact.avatar != null && systemContact.avatar.length > 0) {
            _contactRepository.update(id: contactId);
            filePath = "$avatarPath/${email.value}_avatar.png";
            File file = File(filePath);
            FileImage image = FileImage(file);
            image.evict();
            await file.writeAsBytes(systemContact.avatar);
          }
          var contactExtension = await contactExtensionProvider.get(contactId: contactId);
          if (contactExtension == null) {
            contactExtension = ContactExtension(contactId, avatar: filePath);
            contactExtensionProvider.insert(contactExtension);
          } else {
            contactExtension.avatar = filePath;
            contactExtensionProvider.update(contactExtension);
          }
        }
      });
    });
  }

  Future<int> updateContacts(String coreContacts, Context context) async {
    int changedCount = 0;
    if (coreContacts != null && coreContacts.isNotEmpty) {
      changedCount = await context.addAddressBook(coreContacts);
    }
    return changedCount;
  }

  Future updateContactExtensions(List<int> contactIds, Map<String, String> phoneNumbers) async {
    var contactExtensionProvider = ContactExtensionProvider();
    _contactRepository.update(ids: contactIds);
    contactIds.forEach((contactId) async {
      var contact = _contactRepository.get(contactId);
      var mail = await contact.getAddress();
      var contactPhoneNumbers = phoneNumbers[mail];
      var contactExtension = await contactExtensionProvider.get(contactId: contactId);
      if (contactPhoneNumbers != null && contactPhoneNumbers.isNotEmpty) {
        if (contactExtension == null) {
          contactExtension = ContactExtension(contactId, phoneNumbers: contactPhoneNumbers);
          contactExtensionProvider.insert(contactExtension);
        } else {
          contactExtension.phoneNumbers = contactPhoneNumbers;
          contactExtensionProvider.update(contactExtension);
        }
      } else {
        if (contactExtension != null) {
          contactExtension.phoneNumbers = "";
          contactExtensionProvider.update(contactExtension);
        }
      }
    });
  }

  Future<String> _avatarPathAsync() async {
    final applicationSupportDirectory = await getApplicationSupportDirectory();
    final avatarPath = "${applicationSupportDirectory.path}/avatars";
    final avatarDir = Directory(avatarPath);
    if (await avatarDir.exists() == false) {
      avatarDir.createSync(recursive: true);
    }
    return avatarPath;
  }
}
