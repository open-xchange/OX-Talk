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

// Imports the Flutter Driver API.
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

void main() {
  group('Create chat list integration tests', () {
// Define the driver.
    FlutterDriver driver;
    final timeout = Duration(seconds: 120);

    final realEmail = 'enyakam3@ox.com';
    final realPassword = 'secret';
    final singIn = 'SIGN IN';
    final coiDebug = 'Coi debug';
    final meContact = "Me";
    final profile = "Profile";
    final chat = "Chats";
    final contacts = "Contacts";
    final profileUserStatus =
        "Sent with OX Coi Messenger - https://github.com/open-xchange/ox-coi";
    final loginCheckMail = L.getKey(L.loginCheckMail);
    final noFlaggedButtonFinder = find.text(L.getKey(L.chatNoFlagged));
    final searchReturnIconButton = find.byValueKey(keySearchReturnIconButton);
    final finderUserProfileEmailText = find.byValueKey(keyUserProfileEmailText);

//  SerializableFinder.
    final finderCoiDebugProvider = find.text(coiDebug);
    final finderProviderEmail =
        find.byValueKey(keyProviderSignInEmailTextField);
    final finderProviderPassword =
        find.byValueKey(keyProviderSignInPasswordTextField);
    final finderSIGNIN = find.text(singIn);

    final cancelFinder = find.byValueKey(keyDialogBuilderCancelFlatButton);
    final personAddFinder =
        find.byValueKey(keyContactListPersonAddFloatingActionButton);
    final contactChangeNameFinder =
        find.byValueKey(keyContactChangeNameValidatableTextFormField);
    final contactChangeEmailFinder =
        find.byValueKey(keyContactChangeEmailValidatableTextFormField);
    final contactChangeCheckFinder =
        find.byValueKey(keyContactChangeCheckIconButton);
    final finderCreateChat =
        find.byValueKey(keyChatListChatFloatingActionButton);
    final profileFinder = find.text(profile);
    final contactsFinder = find.text(contacts);
    final chatsFinder = find.text(chat);
    final finderUserProfileStatusText = find.text(profileUserStatus);

    final finderUserProfileEditRaisedButton =
        find.byValueKey(keyUserProfileEditProfileRaisedButton);
    final finderUserSettingsCheckIconButton =
        find.byValueKey(keyUserSettingsCheckIconButton);
    final userSettingsUserSettingsUsernameLabel =
        find.byValueKey(keyUserSettingsUserSettingsUsernameLabel);

    //  SerializableFinder for the Ox coi welcome and provider page.

//  SerializableFinder for profile and edit profile windows.

    // Connect to a running Flutter application instance.
    setUpAll(() async {
      final String adbPath =
          '/Users/openxchange/Library/Android/sdk/platform-tools/adb';
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.WRITE_CONTACTS'
      ]);
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.READ_CONTACTS'
      ]);
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.RECORD_AUDIO'
      ]);

      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.READ_EXTERNAL_STORAGE'
      ]);
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.openxchange.oxcoi.dev',
        'android.permission.WRITE_EXTERNAL_STORAGE'
      ]);
      driver = await FlutterDriver.connect();
      driver.setSemantics(true, timeout: timeout);
    });

//  Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Test Create chat list integration tests', () async {
      //  Get and print driver status.
      await driver.waitFor(finderSIGNIN);
      await driver.tap(finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/providerList1.png');

      //  Check real authentication and get chat.
      await driver.tap(finderCoiDebugProvider);
      print('\nReal authentication.');
      await getAuthentication(driver, finderProviderEmail, realEmail,
          finderProviderPassword, realPassword, finderSIGNIN);

      await driver.tap(profileFinder);
      await driver.tap(contactsFinder);
      await driver.tap(cancelFinder);
      await driver.tap(chatsFinder);

      //  Test chat navigation.
      await checkChat(
          driver,
          finderCreateChat,
          searchReturnIconButton,
          noFlaggedButtonFinder,
          realEmail,
          meContact,
          loginCheckMail,
          contactChangeNameFinder,
          contactChangeEmailFinder);

      //  Test contact navigation.
      await checkContact(
          driver,
          searchReturnIconButton,
          personAddFinder,
          contactChangeNameFinder,
          meContact,
          contactChangeEmailFinder,
          contactChangeCheckFinder,
          loginCheckMail,
          contactsFinder,
          cancelFinder,
          meContact);

      //  Test profile navigation.
      await checkProfile(
          driver,
          profileFinder,
          finderUserProfileEmailText,
          finderUserProfileStatusText,
          finderUserProfileEditRaisedButton,
          userSettingsUserSettingsUsernameLabel,
          finderUserSettingsCheckIconButton,
          chatsFinder);
    });
  });
}

Future checkProfile(
    FlutterDriver driver,
    SerializableFinder profileFinder,
    SerializableFinder finderUserProfileEmailText,
    SerializableFinder finderUserProfileStatusText,
    SerializableFinder finderUserProfileEditRaisedButton,
    SerializableFinder userSettingsUserSettingsUsernameLabel,
    SerializableFinder finderUserSettingsCheckIconButton,
    SerializableFinder chatsFinder) async {
  await driver.tap(profileFinder);
  await catchScreenshot(driver, 'screenshots/checkProfile.png');
  await driver.waitFor(finderUserProfileEmailText);
  await driver.waitFor(finderUserProfileStatusText);
  await driver.tap(finderUserProfileEditRaisedButton);
  Invoker.current.heartbeat();
  await driver.tap(userSettingsUserSettingsUsernameLabel);
  print('\nGet Profile after changes saved and check changes.');
  await driver.tap(finderUserSettingsCheckIconButton);
  //await driver.tap(finderRootIconProfileTextTitle);
  await driver.waitFor(finderUserProfileEmailText);
  await driver.waitFor(finderUserProfileStatusText);
  print("\nUser name, status, email after edited profile is ok.");
  Invoker.current.heartbeat();
  await catchScreenshot(driver, 'screenshots/UserChangeProfile.png');
  await driver.tap(chatsFinder);
}

Future getAuthentication(
    FlutterDriver driver,
    SerializableFinder email,
    String fakeEmail,
    SerializableFinder password,
    String realPassword,
    SerializableFinder SIGNIN) async {
  await driver.tap(email);
  await driver.enterText(fakeEmail);
  await driver.waitFor(email);
  await driver.tap(password);
  await driver.enterText(realPassword);
  Invoker.current.heartbeat();
  await driver.tap(SIGNIN);
  Invoker.current.heartbeat();
}

//  Take screenshot
Future catchScreenshot(FlutterDriver driver, String path) async {
  final List<int> pixels = await driver.screenshot();
  final File file = new File(path);
  await file.writeAsBytes(pixels);
  print(path);
}

Future checkChat(
    FlutterDriver driver,
    SerializableFinder finderCreateChat,
    SerializableFinder searchReturnIconButton,
    SerializableFinder noFlaggedButtonFinder,
    String chatEmail,
    String chatName,
    String loginCheckMail,
    SerializableFinder keyContactChangeNameFinder,
    SerializableFinder keyContactChangeEmailFinder) async {
  final newContact = L.getKey(L.contactNew);
  final name = L.getKey(L.name);
  final enterContactName = L.getKey(L.contactName);
  final emailAddress = L.getKey(L.emailAddress);
  final chatCreate = L.getKey(L.chatCreate);
  final finderMe = find.text(chatName);
  final finderNewContact = find.text(newContact);


  //  Check flaggedButton.
  await driver.tap(find.byValueKey(keyChatListGetFlaggedActionIconButton));
  await driver.waitFor(noFlaggedButtonFinder);
  await driver.waitFor(find.byValueKey(L.getKey(L.chatFavoriteMessages)));
  await driver.waitFor(find.byValueKey(L.getKey(L.chatFlagged)));
  await driver.tap(find.pageBack());
  await catchScreenshot(driver, 'screenshots/afterFlaged.png');

  Invoker.current.heartbeat();
  await driver.tap(finderCreateChat);
  await driver.waitFor(find.text(chatCreate));
  await catchScreenshot(driver, 'screenshots/me1.png');


  //  Check newContact.
  await driver.tap(finderCreateChat);
  await driver.tap(finderNewContact);
  await driver.waitFor(find.text(name));
  await driver.waitFor(find.text(emailAddress));
  await driver.tap(keyContactChangeNameFinder);
  await driver.waitFor(find.text(enterContactName));
  await driver.tap(keyContactChangeEmailFinder);
  await driver.waitFor(find.text(emailAddress));
  await driver.tap(find.byValueKey(keyContactChangeCheckIconButton));
  await catchScreenshot(driver, 'screenshots/checkNewContact.png');
  await driver.waitFor(find.text(loginCheckMail));
  await driver.tap(find.byValueKey(keyContactChangeCloseIconButton));
  await driver.tap(find.pageBack());
  await driver.waitFor(finderMe);

  Invoker.current.heartbeat();
  await driver.tap(find.byValueKey(keyChatListSearchIconButton));
  await driver.waitFor(find.text("Me"));
  await driver.tap(find.byValueKey(keySearchClearIconButton));
  await driver.tap(searchReturnIconButton);
}

Future checkContact(
    FlutterDriver driver,
    SerializableFinder searchReturnIconButton,
    SerializableFinder personAddFinder,
    SerializableFinder keyContactChangeNameFinder,
    String newTestName,
    SerializableFinder keyContactChangeEmailFinder,
    SerializableFinder keyContactChangeCheckFinder,
    String loginCheckMail,
    SerializableFinder contactsFinder,
    SerializableFinder cancelFinder,
    String meContact) async {
  await driver.tap(contactsFinder);
  //await driver.tap(cancelFinder);
  await driver.waitFor(find.text(meContact));
  Invoker.current.heartbeat();
  await driver.tap(personAddFinder);
  await driver.tap(keyContactChangeNameFinder);
  await driver.tap(keyContactChangeEmailFinder);
  Invoker.current.heartbeat();
  await driver.tap(keyContactChangeCheckFinder);
  await catchScreenshot(driver, 'screenshots/person_add01.png');
  await driver.waitFor(find.text(loginCheckMail));
  await driver.tap(find.byValueKey(keyContactChangeCloseIconButton));
  await driver.waitFor(find.text(newTestName));
  await catchScreenshot(driver, 'screenshots/persone_add02.png');

  //  Check import contact
  await driver.tap(find.byValueKey(keyContactListImportContactIconButton));
  await driver.tap(cancelFinder);
  await driver.tap(find.byValueKey(keyContactListBlockIconButton));
  await driver.waitFor(find.text(L.getKey(L.contactNoBlocked)));
  await driver.tap(find.byValueKey(keyContactBlockedListCloseIconButton));
  await driver.tap(find.byValueKey(keyContactListSearchIconButton));
  await driver.waitFor(find.text(newTestName));
  await driver.tap(searchReturnIconButton);
  print('\nNew contact is added');
}
