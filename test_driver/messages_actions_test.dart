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
import 'package:test/test.dart';
import 'package:ox_coi/src/l10n/l.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  group('Test messages fonctionslity', () {
    var setup = Setup();
    setup.perform();

    final openChat = 'Open chat';
    final flagUnFlag = 'Flag/Unflag';
    final forward = 'Forward';
    final textToDelete = 'Text to delete';
    final paste = 'PASTE';
    final copy = 'Copy';

    final meContactFinder = find.text(meContact);
    final textToDeleteFinder = find.text(textToDelete);

    test(': Get contacts and add new contacts.', () async {
      await setup.driver.tap(contactsFinder);
      await setup.driver.tap(cancelFinder);
      expect(await setup.driver.getText(meContactFinder), meContact);
      await addNewContact(
        setup.driver,
        newTestName01,
        newTestEmail04,
      );
    });

    test(': Create chat and write something.', () async {
      await setup.driver.tap(meContactFinder);
      await setup.driver.tap(find.text(openChat));
      await writeChatFromChat(setup.driver);
    });

    test(': Flagged messages from  meChat.', () async {
      await flaggedMessage(setup.driver, flagUnFlag, helloWorldFinder);
      await setup.driver.tap(pageBack);
      await navigateTo(setup.driver, L.getPluralKey(L.chatP));
     });

    test(': UnFlagged messages.', () async {
      await unFlaggedMessage(setup.driver, flagUnFlag, helloWorld);
      await setup.driver.waitForAbsent(helloWorldFinder);
      await setup.driver.tap(pageBack);
      await setup.driver.tap(meContactFinder);
    });

    test(': Forward message.', () async {
      await forwardMessageTo(setup.driver, newTestName01, forward);
      expect(await setup.driver.getText(helloWorldFinder), helloWorld);
      await setup.driver.tap(pageBack);
      await setup.driver.tap(meContactFinder);
    });

    test(': Copy message from meContact and it paste in meContact.', () async {
      await copyAndPasteMessage(setup.driver, copy, paste);
    });

    test(': Enter new text to delete.', () async {
      await writeTextInChat(setup.driver, textToDelete);
      expect(await setup.driver.getText(textToDeleteFinder), textToDelete);
    });

    test(': Delete message.', () async {
      await deleteMessage(textToDeleteFinder, setup.driver);
      await setup.driver.waitForAbsent(textToDeleteFinder);
    });
  });
}
