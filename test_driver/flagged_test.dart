/*
 *
 *  * OPEN-XCHANGE legal information
 *  *
 *  * All intellectual property rights in the Software are protected by
 *  * international copyright laws.
 *  *
 *  *
 *  * In some countries OX, OX Open-Xchange and open xchange
 *  * as well as the corresponding Logos OX Open-Xchange and OX are registered
 *  * trademarks of the OX Software GmbH group of companies.
 *  * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 *  * Instead, you are allowed to use these Logos according to the terms and
 *  * conditions of the Creative Commons License, Version 2.5, Attribution,
 *  * Non-commercial, ShareAlike, and the interpretation of the term
 *  * Non-commercial applicable to the aforementioned license is published
 *  * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *  *
 *  * Please make sure that third-party modules and libraries are used
 *  * according to their respective licenses.
 *  *
 *  * Any modifications to this package must retain all copyright notices
 *  * of the original copyright holder(s) for the original code used.
 *  *
 *  * After any such modifications, the original and derivative code shall remain
 *  * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 *  * https://www.open-xchange.com/legal/. The contributing author shall be
 *  * given Attribution for the derivative code and a license granting use.
 *  *
 *  * Copyright (C) 2016-2020 OX Software GmbH
 *  * Mail: info@open-xchange.com
 *  *
 *  *
 *  * This Source Code Form is subject to the terms of the Mozilla Public
 *  * License, v. 2.0. If a copy of the MPL was not distributed with this
 *  * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *  *
 *  * This program is distributed in the hope that it will be useful, but
 *  * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 *  * for more details.
 *
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

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:test/test.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';

import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';
import 'setup/test_constants.dart';

void main() {
  FlutterDriver driver;
  setUpAll(() async {
    driver = await setupAndGetDriver();
  });

  tearDownAll(() async {
    await teardownDriver(driver);
  });

  group('Test flagged messages per chat', () {
    final flagUnFlag = L.getKey(L.messageActionFlagUnflag);
    final name2ContactFinder = find.text(name2);
    final name3ContactFinder = find.text(name3);

    test(': Add two chats.', () async {
      await createNewChat(driver, email2, name2);
      await createNewChat(driver, email3, name3);
    });

    test(': Edit two messages in chat name2 and flags both. ', () async {
      await driver.tap(name2ContactFinder);
      await writeTextInChat(driver, messageIdOne);
      await writeTextInChat(driver, messageIdTwo,inputTestMessage);
      await flaggedMessage(driver, flagUnFlag, finderMessageOne);
      await flaggedMessage(driver, flagUnFlag, finderMessageTwo);
      await driver.tap(pageBackFinder);
    });

    test(': Edit one messages in chat name3 ', () async {
      await driver.tap(name3ContactFinder);
      await writeTextInChat(driver, messageIdThree);
      await flaggedMessage(driver, flagUnFlag, finderMessageThree);
    });

    test(': Check flagged messages. ', () async {
      await driver.tap(find.byValueKey(keyChatIconTitleText));
      await driver.tap(find.byValueKey(keyChatProfileSingleIconSourceFlaggedTitle));
      await driver.waitFor(finderMessageOne);
      await driver.waitFor(finderMessageTwo);
      await driver.waitFor(finderMessageThree);
      await driver.tap(pageBackFinder);
    });

    test(': UnFlagged messages.', () async {
      await driver.tap(name3ContactFinder);
      await driver.tap(find.byValueKey(keyChatProfileSingleIconSourceFlaggedTitle));
      await unFlaggedMessage(driver, flagUnFlag, messageIdOne);
      await unFlaggedMessage(driver, flagUnFlag, messageIdTwo);
      await unFlaggedMessage(driver, flagUnFlag, messageIdThree);
      await driver.waitForAbsent(finderMessageOne);
      await driver.waitForAbsent(finderMessageTwo);
      await driver.waitForAbsent(finderMessageThree);
      await driver.tap(pageBackFinder);
    });
  });
}
