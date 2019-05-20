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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ox_coi/src/l10n/messages_all.dart';

class AppLocalizations {
  static get supportedLocales => [
        const Locale('en', 'US'),
      ];

  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  //add new translations here
  //call 'flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/source/l10n lib/source/l10n/localizations.dart' in the terminal
  //copy intl_messages.arb and create language specific intl_[language_code].arb files (e.g. intl_en.arb) and translate the file
  //call flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/source/l10n \ --no-use-deferred-loading lib/source/l10n/localizations.dart lib/source/l10n/intl_*.arb
  //translation complete

  // No translation
  String get sslTls => 'SSL/TLS';

  String get startTLS => 'StartTLS';

  String get bigDot => '\u2B24';

  String get feedbackUrl => 'https://github.com/open-xchange/ox-coi';

  // Global
  String get yes => Intl.message('Yes', name: 'yes');

  String get no => Intl.message('No', name: 'no');

  String get delete => Intl.message('Delete', name: 'delete');

  String get import => Intl.message('Import', name: 'import');

  String get advanced => Intl.message('Advanced', name: 'advanced');

  String get inbox => Intl.message('Inbox', name: 'inbox');

  String get outbox => Intl.message('Outbox', name: 'outbox');

  String get emailAddress => Intl.message('Email address', name: 'emailAddress');

  String get password => Intl.message('Password', name: 'password');

  String get automatic => Intl.message('Automatic', name: 'automatic');

  String get off => Intl.message('Off', name: 'off');

  String get name => Intl.message('Name', name: 'name');

  String get ok => Intl.message('Ok', name: 'ok');

  String get cancel => Intl.message('Cancel', name: 'cancel');

  String get block => Intl.message('Block', name: 'block');

  String get unblock => Intl.message('Unblock', name: 'unblock');

  String get gallery => Intl.message('Gallery', name: 'gallery');

  String get camera => Intl.message('Camera', name: 'camera');

  String get invites => Intl.message('Invites', name: 'invites');

  String get chats => Intl.message('Chats', name: 'chats');

  String get video => Intl.message('Video', name: 'video');

  String get image => Intl.message('Image', name: 'image');

  String get poll => Intl.message('Poll', name: 'poll');

  String get location => Intl.message('Location', name: 'location');

  String get file => Intl.message('File', name: 'file');

  String get gif => Intl.message('GIF', name: 'gif');

  String get pdf => Intl.message('PDF', name: 'pdf');

  String get copiedToClipboard => Intl.message('Copied to clipboard', name: 'copiedToClipboard');

  String get today => Intl.message('Today', name: 'today');

  String get yesterday => Intl.message('Yesterday', name: 'yesterday');

  String get participants => Intl.message('Participants', name: 'participants');

  String get settings => Intl.message('Settings', name: 'settings');

  String get security => Intl.message('Security', name: 'security');

  String get forward => Intl.message('Forward', name: 'forward');

  String get share => Intl.message('Share', name: 'share');

  String get contacts => Intl.message('Contacts', name: 'contacts');

  String get about => Intl.message('About', name: 'about');

  String get feedback => Intl.message('Feedback', name: 'feedback');

  // Core
  String get coreChatStatusDefaultValue => "Sent with my Delta Chat Messenger: https://delta.chat";

  String get coreChatNoMessages => Intl.message('No messages', name: 'coreChatNoMessages');

  String get coreSelf => Intl.message('Me', name: 'coreSelf');

  String get coreDraft => Intl.message('Draft', name: 'coreDraft');

  String get coreMembers => Intl.message('%1\$d member(s)', name: 'coreMembers');

  String get coreContacts => Intl.message('%1\$d contact(s)', name: 'coreContacts');

  String get coreVoiceMessage => Intl.message('Voice message', name: 'coreVoiceMessage');

  String get coreContactRequest => Intl.message('Contact request', name: 'coreContactRequest');

  String get coreImage => Intl.message('Image', name: 'coreImage');

  String get coreVideo => Intl.message('Video', name: 'coreVideo');

  String get coreAudio => Intl.message('Audio', name: 'coreAudio');

  String get coreFile => Intl.message('File', name: 'coreFile');

  String get coreGroupHelloDraft => Intl.message('Hello, I\'ve just created this group for us', name: 'coreGroupHelloDraft');

  String get coreGroupNameChanged => Intl.message('Group name changed', name: 'coreGroupNameChanged');

  String get coreGroupImageChanged => Intl.message('Group image changed', name: 'coreGroupImageChanged');

  String get coreGroupMemberAdded => Intl.message('Member added', name: 'coreGroupMemberAdded');

  String get coreGroupMemberRemoved => Intl.message('Member removed', name: 'coreGroupMemberRemoved');

  String get coreGroupLeft => Intl.message('Group left', name: 'coreGroupLeft');

  String get coreGenericError => Intl.message('Error: ', name: 'coreGenericError');

  String get coreGif => Intl.message('Gif', name: 'coreGif');

  String get coreMessageCannotDecrypt => Intl.message(
      'This message cannot be decrypted.\n\n'
      '• It might already help to simply reply to this message and ask the sender to send the message again.\n\n'
      '• In case you re-installed OX Coi or another email program on this or another device you may want to send an Autocrypt Setup Message from there.',
      name: 'coreMessageCannotDecrypt');

  String get coreReadReceiptSubject => Intl.message('Read receipt', name: 'coreReadReceiptSubject');

  String get coreReadReceiptBody => Intl.message(
      'This is a read receipt.\n\nIt means the message was displayed on the recipient\'s device, not necessarily that the content was read.',
      name: 'coreReadReceiptBody');

  String get coreGroupImageDeleted => Intl.message('Group image deleted', name: 'coreGroupImageDeleted');

  String get coreContactVerified => Intl.message('Contact verified', name: 'coreContactVerified');

  String get coreContactNotVerified => Intl.message('Cannot verify contact', name: 'coreContactNotVerified');

  String get coreContactSetupChanged => Intl.message('Changed setup for contact', name: 'coreContactSetupChanged');

  String get coreArchivedChats => Intl.message('Archived chats', name: 'coreArchivedChats');

  String get coreAutoCryptSetupSubject => Intl.message('Autocrypt Setup Message', name: 'coreAutoCryptSetupSubject');

  String get coreAutoCryptSetupBody => Intl.message(
      'This is the Autocrypt Setup Message used to transfer your end-to-end setup between clients.\n\n'
      'To decrypt and use your setup, open the message in an Autocrypt-compliant client and enter the setup code presented on the generating device.',
      name: 'coreAutoCryptSetupBody');

  String get coreChatSelf => Intl.message('Messages I sent to myself', name: 'coreChatSelf');

  String get coreLoginErrorCannotLogin =>
      Intl.message('Cannot login. Please check if the email-address and the password are correct.', name: 'coreLoginErrorCannotLogin');

  String get coreLoginErrorServerResponse => Intl.message(
      'Response from %1\$s: %1\$2\n\n'
      'Some providers place additional information in your inbox; you can check them it eg. in the web frontend. Consult your provider or friends if you run into problems.',
      name: 'coreLoginErrorServerResponse');

  String get coreActionByUser => Intl.message('%1\$s by %1\$2', name: 'coreActionByUser');

  String get coreActionByMe => Intl.message('%1\$s by me', name: 'coreActionByMe');

  // Form
  String get validatableTextFormFieldHintInvalidEmail =>
      Intl.message('Please enter a valid e-mail address', name: 'validatableTextFormFieldHintInvalidEmail');

  String get validatableTextFormFieldHintInvalidPort =>
      Intl.message('Please enter a valid port (1-65535)', name: 'validatableTextFormFieldHintInvalidPort');

  String get validatableTextFormFieldHintInvalidPassword =>
      Intl.message('Please enter your password', name: 'validatableTextFormFieldHintInvalidPassword');

  String get validatableTextFormFieldHintEmptyString => Intl.message('This field can not be empty', name: 'validatableTextFormFieldHintEmptyString');

  // Login
  String get loginTitle => Intl.message('Login to OX Coi', name: 'loginTitle');

  String get loginInformation => Intl.message(
      'For known email providers additional settings are setup automatically. Sometimes IMAP needs to be enabled in the web frontend. Consult your email provider or friends for help.',
      name: 'loginInformation');

  String get loginHintEmail => Intl.message('Enter your email address', name: 'loginLabelEmail');

  String get loginHintPassword => Intl.message('Enter your password', name: 'loginHintPassword');

  String get loginLabelImapName => Intl.message('IMAP login-name', name: 'loginLabelImapName');

  String get loginLabelEmail => Intl.message('E-mail address', name: 'loginLabelEmail');

  String get loginLabelImapPassword => Intl.message('IMAP password', name: 'loginLabelImapPassword');

  String get loginLabelImapServer => Intl.message('IMAP server', name: 'loginLabelImapServer');

  String get loginLabelImapPort => Intl.message('IMAP port', name: 'loginLabelImapPort');

  String get loginLabelImapSecurity => Intl.message('IMAP Security', name: 'loginLabelImapSecurity');

  String get loginLabelSmtpName => Intl.message('SMTP login-name', name: 'loginLabelSmtpName');

  String get loginLabelSmtpPassword => Intl.message('SMTP password', name: 'loginLabelSmtpPassword');

  String get loginLabelSmtpServer => Intl.message('SMTP server', name: 'loginLabelSmtpServer');

  String get loginLabelSmtpPort => Intl.message('SMTP port', name: 'loginLabelSmtpPort');

  String get loginLabelSmtpSecurity => Intl.message('SMTP Security', name: 'loginLabelSmtpSecurity');

  String get loginProgressMessage => Intl.message('Logging in, this may take a moment', name: 'loginProgressMessage');

  String get loginErrorDialogTitle => Intl.message('Login failed', name: 'loginErrorDialogTitle');

  // Mail
  String get mailTitle => Intl.message('Mail', name: 'mailTitle');

  // Chat list / invite list
  String get inviteEmptyList => Intl.message('No invites', name: 'inviteEmptyList');

  String get chatListEmpty => Intl.message('No chats', name: 'chatListEmpty');

  String get chatListDeleteChatsDialogTitleText => Intl.message('Delete chats', name: 'chatListDeleteChatsDialogTitleText');

  String get chatListDeleteChatsInfoText => Intl.message('Do you want to delete these chats?', name: 'chatListDeleteChatsInfoText');

  // Chat
  String get chatTitle => Intl.message('Chat', name: 'chatTitle');

  String get composePlaceholder => Intl.message('Type something...', name: 'composePlaceholder');

  String get recordingAudioMessageFailure => Intl.message('Audio recording failed, missing permissions', name: 'recordingAudioMessageFailure');

  String get recordingVideoMessageFailure => Intl.message('Video recording failed, missing permissions', name: 'recordingVideoMessageFailure');

  // Chat profile view
  String get chatProfileBlockContactInfoText => Intl.message('Do you want to block the contact?', name: 'chatProfileBlockContactInfoText');

  String get chatProfileBlockContactButtonText => Intl.message('Block contact', name: 'chatProfileBlockContactButtonText');

  String get chatProfileDeleteChatButtonText => Intl.message('Delete chat', name: 'chatProfileDeleteChatButtonText');

  String get chatProfileDeleteChatInfoText => Intl.message('Do you want to delete this chat?', name: 'chatProfileDeleteChatInfoText');

  String get chatProfileClipboardToastMessage => Intl.message('Email copied to clipboard', name: 'chatProfileClipboardToastMessage');

  String get chatProfileLeaveGroupInfoText => Intl.message('Do you really want to leave the group?', name: 'chatProfileLeaveGroupInfoText');

  String get chatProfileLeaveGroupButtonText => Intl.message('Leave group', name: 'chatProfileLeaveGroupButtonText');

  String chatProfileGroupMemberCounter(memberCount) =>
      Intl.message('$memberCount member(s)', name: 'chatProfileGroupMemberCounter', args: [memberCount]);

  // Create chat
  String get createChatTitle => Intl.message('Create chat', name: 'createChatTitle');

  String get createChatNewContactButtonText => Intl.message('New contact', name: 'createChatNewContactButtonText');

  String createChatWith(name) => Intl.message('Start a chat with $name?', name: 'createChatWith', args: [name]);

  // Create group
  String get createGroupButtonText => Intl.message('Create group', name: 'createGroupButtonText');

  String get createGroupNameAndAvatarHeader => Intl.message('Group name', name: 'createChatCreateGroupNameAndAvatarHeader');

  String get createGroupNoParticipantsHint => Intl.message('Simply add one by tapping on a contact.', name: 'createGroupNoParticipantsHint');

  String get createGroupNoParticipantsSelected =>
      Intl.message('No participants selected. Please select at least one person.', name: 'createGroupNoParticipantsSelected');

  String get createGroupTitle => Intl.message('Create group chat', name: 'createGroupTitle');

  String get createGroupTextFieldLabel => Intl.message('Group name', name: 'createGroupTextFieldLabel');

  String get createGroupTextFieldHint => Intl.message('Set a group name', name: 'createGroupTextFieldHint');

  // Contact
  String get contactChangeAddTitle => Intl.message('Add Contact', name: 'contactChangeAddTitle');

  String get contactChangeAddToast => Intl.message('Contact successfully added', name: 'contactChangeAddToast');

  String get contactChangeEditTitle => Intl.message('Edit Name', name: 'contactChangeEditTitle');

  String get contactChangeEditToast => Intl.message('Contact successfully edited', name: 'contactChangeEditToast');

  String get contactChangeDeleteTitle => Intl.message('Delete Contact', name: 'contactChangeDeleteTitle');

  String get contactChangeDeleteToast => Intl.message('Contact successfully deleted', name: 'contactChangeDeleteToast');

  String get contactChangeDeleteFailedToast => Intl.message('Could not delete contact.', name: 'contactChangeDeleteFailedToast');

  String contactChangeDeleteDialogContent(email, name) =>
      Intl.message('Do you really want to delete $email ($name)?', name: 'contactChangeDeleteDialogContent', args: [email, name]);

  String get contactChangeNameHint => Intl.message('Enter the contact name', name: 'contactChangeNameHint');

  String get contactImportDialogTitle => Intl.message('Import system contacts', name: 'contactImportDialogTitle');

  String get contactImportDialogContent => Intl.message('Would you like to import your system contacts?', name: 'contactImportDialogContent');

  String get contactImportDialogContentExtensionInitial =>
      Intl.message('This action can be also done later via the import button in the top action bar.', name: 'contactImportDialogContent');

  String get contactImportDialogContentExtensionRepeat =>
      Intl.message('Re-importing your contacts will not create duplicates.', name: 'contactImportDialogContent');

  String contactImportSuccess(count) => Intl.message('$count system contacts imported', name: 'contactImportSuccess', args: [count]);

  String get contactImportFailure => Intl.message('Import failed, missing permissions', name: 'contactImportFailure');

  String get contactsSearchHint => Intl.message('Search contacts', name: 'contactsSearchHint');

  //BlockedContacts
  String get blockedContactsTitle => Intl.message('Blocked contacts', name: 'blockedContactsTitle');

  String get unblockDialogTitle => Intl.message('Unblock contact', name: 'unblockDialogTitle');

  String unblockDialogText(name) => Intl.message('Do you want to unblock $name?', name: 'unblockDialogText', args: [name]);

  String get blockedListEmpty => Intl.message('No blocked contacts', name: 'blockedListEmpty');

  // Profile
  String get profileTitle => Intl.message('Profile', name: 'profileTitle');

  String get profileUsernamePlaceholder => Intl.message('No username set', name: 'profileUsernamePlaceholder');

  String get profileStatusPlaceholder => Intl.message('No status set', name: 'profileStatusPlaceholder');

  String get profileEditButton => Intl.message('Edit profile', name: 'profileEditButton');

  // User settings
  String get userSettingsTitle => Intl.message('Edit user settings', name: 'userSettingsTitle');

  String get userSettingsUsernameLabel => Intl.message('Username', name: 'userSettingsUsernameLabel');

  String get userSettingsStatusLabel => Intl.message('Status', name: 'userSettingsStatusLabel');

  String get userSettingsSaveButton => Intl.message('Save', name: 'userSettingsSaveButton');

  String get userSettingsStatusDefaultValue =>
      Intl.message('Sent with OX Coi - https://github.com/open-xchange/ox-coi', name: 'userSettingsStatusDefaultValue');

  String get userSettingsRemoveImage => Intl.message('Remove current image', name: 'userSettingsRemoveImage');

  // Account settings
  String get accountSettingsTitle => Intl.message('Account settings', name: 'accountSettingsTitle');

  String get accountSettingsDataProgressMessage => Intl.message('Applying new settings, this may take a moment', name: 'accountSettingsDataProgressMessage');

  String get accountSettingsSuccess => Intl.message('Account settings succesfully changed', name: 'accountSettingsSuccess');

  String get accountSettingsErrorDialogTitle => Intl.message('Configuration change aborted', name: 'accountSettingsErrorDialogTitle');

  // Security settings
  String get securitySettingsExportKeys => Intl.message('Export keys', name: 'securitySettingsExportKeys');

  String get securitySettingsExportKeysText => Intl.message('Use this keys to enable another device to use your current security setup', name: 'securitySettingsExportKeysText');

  String securitySettingsExportKeysDialog(path) => Intl.message('Do you want to save your keys in "$path"?', name: 'securitySettingsExportKeysDialog', args: [path]);

  String get securitySettingsExportKeysPerforming => Intl.message('Performing key export', name: 'securitySettingsExportKeysPerforming');

  String get securitySettingsImportKeys => Intl.message('Import keys', name: 'securitySettingsImportKeys');

  String get securitySettingsImportKeysText => Intl.message('Load keys from your local storage to change your current security setup', name: 'securitySettingsImportKeysText');

  String securitySettingsImportKeysDialog(path) => Intl.message('Do you want to load your keys from "$path"? If there are no keys in that folder, the operation will fail.', name: 'securitySettingsImportKeysDialog', args: [path]);

  String get securitySettingsImportKeysPerforming => Intl.message('Performing key import', name: 'securitySettingsImportKeysPerforming');

  String get securitySettingsKeyActionSuccess => Intl.message('Key action successfully done', name: 'securitySettingsKeyActionSuccess');

  String get securitySettingsKeyActionFailed => Intl.message('Key action failed', name: 'securitySettingsKeyActionFailed');

  // About
  String get aboutSettingsName => Intl.message('App name', name: 'aboutSettingsName');

  String get aboutSettingsVersion => Intl.message('App version', name: 'aboutSettingsVersion');

  // Notifications
  String get moreMessages => Intl.message('more messages', name: 'moreMessages');

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    //TODO: add new locales here like: return ['en', 'es', 'de'].contains(locale.languageCode);
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
