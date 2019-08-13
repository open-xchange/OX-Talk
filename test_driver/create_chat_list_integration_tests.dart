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
  group('Create chat list integration tests', () {
// Define the driver.
    FlutterDriver driver;
    final timeout = Duration(seconds: 120);
    final realEmail = 'enyakam3@ox.com';
    final realPassword = 'secret';
    final singIn = 'SIGN IN';
    final coiDebug = 'Coi debug';
    final mailCom = 'Mail.com';
    final chatWelcomeMessage = 'Welcome to OX Coi!\nPlease start a new chat by tapping the chat bubble icon.';

//  SerializableFinder for the Ox coi welcome and provider page.
    final finderCoiDebugProvider = find.text(coiDebug);
    final finderMailComProvider = find.text(mailCom);

//  SerializableFinder for Coi Debug dialog Windows.
    final finderProviderEmail = find.byValueKey(keyProviderSignInEmailTextField);
    final finderProviderPassword = find.byValueKey(keyProviderSignInPasswordTextField);
    final finderSIGNIN = find.text(singIn);
    final finderChatWelcome = find.text(chatWelcomeMessage);

/*
Start the app (already logged in) on the chat list
Verify the chat list is empty (check the "empty list message")
Push the create chat floating action button
Verify the create chat view is opened (by title)
Push the "Me" contact list entry
Verify the chat view is opened (by title)
Push the back button in  the upper left corner
Verify the chat list is loaded with one entry
Verify the entry is named "Me"
Verify that is does not contain messages by checking the second line of the list entry*/

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

      await driver.waitFor(finderSIGNIN);
      await driver.tap(finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/providerList1.png');
      await driver.scroll(finderMailComProvider, 0, -300, Duration(milliseconds: 300));
      await catchScreenshot(driver, 'screenshots/providerList2.png');
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/CoiDebug.png');

      //  Check real authentication and get chat.
      await driver.tap(finderCoiDebugProvider);
      print('\nReal authentication.');
      await getAuthentication(driver, finderProviderEmail, realEmail, finderProviderPassword, realPassword, finderSIGNIN);
      await catchScreenshot(driver, 'screenshots/entered.png');
      Invoker.current.heartbeat();
      print('\nSIGN IN ist done. Wait for chat.');
      await driver.waitFor(finderChatWelcome);
      Invoker.current.heartbeat();
      await catchScreenshot(driver, 'screenshots/chat.png');
      print('\nGet chat.');

    });
  });
}

Future getAuthentication(FlutterDriver driver, SerializableFinder email, String fakeEmail, SerializableFinder password, String realPassword,
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
