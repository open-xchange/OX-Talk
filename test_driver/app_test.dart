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
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

void main() {
  group('Ox coi test', () {
    //  Define the driver.
    FlutterDriver driver;
    final timeout = Duration(seconds: 120);

    //  SerializableFinder for the Ox coi welcome and provider page.
    final finderWelcomeMessage = find.text('Welcome to OX Coi');
    final finderWelcomeDescription = find.text(
        'OX Coi works with any email account. If you have one, please sign in, otherwise register a new account first.');
    final finderRegisterProvider = find.text('SIGN IN');
    final finderSignInProvider = find.text('Sign in');
    final finderOutlookProvider = find.text('Outlook');
    final finderYahooProvider = find.text('Yahoo');
    final finderCoiDebugProvider = find.text('Coi debug');
    final finderMailComProvider = find.text('Mail.com');
    final finderOtherProvider = find.text('Other mail account');
    final finderMailboxProvider = find.text('Mailbox.org');

    //  SerializableFinder for Coi Debug dialog Windows.
    final finderSignInCoiDebug = find.text('Sign in with Coi debug?');
    final finderProviderEmail =
        find.byValueKey(keyProviderSignInEmailTextField);
    final finderProviderPassword =
        find.byValueKey(keyProviderSignInPasswordTextField);
    final finderSIGNIN = find.text('SIGN IN');
    final finderChatWelcome = find.text(
        'Welcome to OX Coi!\nPlease start a new chat by tapping the chat bubble icon.');

    final finderRootIconChatTextTitle = find.byType(keyRootIconChatTitleText);
    final finderRootIconContactsTextTitle = find.byType(keyRootIconContactsTitleText);
    final finderRootIconProfileTextTitle = find.byValueKey(keyRootIconProfileTitleText);
    final finderUserProfileEditRaisedButton =
        find.byValueKey(keyUserProfileEditProfilRaisedButton);
    final finderUserSettingsCheckIconButton =
        find.byValueKey(keyUserSettingsCheckIconButton);
    final userSettingsUserSettingsUsernameLabel =
        find.byValueKey(keyUserSettingsUserSettingsUsernameLabel);
    final finderUserProfileEmailText= find.byValueKey(keyUserProfileEmailText);

    final userNameUserProfil = 'EDN tester';
    final realEmail = 'enyakam3@ox.com';
    final realPassword = 'secret';

    // Connect to a running Flutter application instance.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      driver.setSemantics(true, timeout: timeout);
    });

    //  Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    //  Take screenshot
    catchScreenshot(FlutterDriver driver, String path) async {
      final List<int> pixels = await driver.screenshot();
      final File file = new File(path);
      await file.writeAsBytes(pixels);
      print(path);
    }

    test('Test create profile integration tests', () async {
      //  Get and print driver status.
      Health health = await driver.checkHealth();
      print(health.status);

      //  Test Ox.coi welcome screen and tap on SIGN In to get the provider list, and test if all provider are contained in the list.
      await checkOxCoiWelcomeAndProviderList(
          driver,
          finderWelcomeMessage,
          finderWelcomeDescription,
          finderSIGNIN,
          finderRegisterProvider,
          finderOutlookProvider,
          finderYahooProvider,
          finderSignInProvider,
          finderCoiDebugProvider,
          finderOtherProvider,
          finderMailboxProvider);
      await catchScreenshot(driver, 'screenshots/providerList1.png');
      await driver.scroll(
          finderMailComProvider, 0, -600, Duration(milliseconds: 500));
      await catchScreenshot(driver, 'screenshots/providerList2.png');
      Invoker.current.heartbeat();
      await selectAndTapProvider(driver, finderCoiDebugProvider,
          finderSignInCoiDebug, finderProviderEmail, finderProviderPassword);

      //await catchScreenshot(driver, 'screenshots/CoiDebug.png');
      //  Check real authentication and get chat.
      print('\nReal authentication.');
      await getAuthentication(driver, finderProviderEmail, realEmail,
          finderProviderPassword, realPassword, finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/entered.png');
      Invoker.current.heartbeat();
      print('\nSIGN IN ist done. Wait for chat.');
      await driver.waitFor(finderChatWelcome);
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/chat.png');
      print('\nGet chat.');
      await driver.tap(finderRootIconProfileTextTitle);
      print('\nGet Profile');
      await driver.tap(finderUserProfileEditRaisedButton);
      Invoker.current.heartbeat();
      print('\nGet user Edit user settings to edit username.');
      await driver.tap(userSettingsUserSettingsUsernameLabel);
      await driver.enterText(userNameUserProfil);
      print('\nReturn to Profile after edited profile.');
      await driver.tap(finderUserSettingsCheckIconButton);
      await driver.waitFor(finderUserProfileEmailText);
     // await driver.waitFor(find.byType('Sent with OX Coi - https://github.com/open-xchange/ox-coi'));
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/UserChangeProfile.png');

      //  Return to chat list.
      await driver.waitFor(finderRootIconChatTextTitle);
      
    });
  });
}

Future checkOxCoiWelcomeAndProviderList(
    FlutterDriver driver,
    SerializableFinder welcomeMessage,
    SerializableFinder welcomeDescription,
    SerializableFinder SIGNIN,
    SerializableFinder register,
    SerializableFinder outlook,
    SerializableFinder yahoo,
    SerializableFinder signIn,
    SerializableFinder coiDebug,
    SerializableFinder other,
    SerializableFinder mailbox) async {
  await driver.waitFor(welcomeMessage);
  await driver.waitFor(welcomeDescription);
  await driver.waitFor(SIGNIN);
  await driver.waitFor(register);
  await driver.tap(SIGNIN);

  //  Check if all providers are found in the list.
  await driver.waitFor(outlook);
  await driver.waitFor(yahoo);
  await driver.waitFor(signIn);
  await driver.waitFor(coiDebug);
  await driver.waitFor(other);
  await driver.waitFor(mailbox);
}

Future selectAndTapProvider(
    FlutterDriver driver,
    SerializableFinder coiDebug,
    SerializableFinder signInCoiDebug,
    SerializableFinder email,
    SerializableFinder password) async {
  await driver.tap(coiDebug);
  await driver.waitFor(signInCoiDebug);
  await driver.waitFor(email);
  await driver.waitFor(password);
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
