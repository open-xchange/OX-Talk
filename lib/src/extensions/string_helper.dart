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
 */

import 'dart:convert';

extension Extract on String {
  static final RegExp matchInvertedNumericAndPlus = RegExp(r'[^0-9+]');
  static final RegExp matchWhiteSpace = RegExp(r'\s');

  String getFirstCharacter() {
    return this.isNotEmpty ? this[0] : null;
  }

  String getPhoneNumberFromString() {
    String phoneNumberWithoutOptionals = this.replaceFirst("(0)", '');
    return phoneNumberWithoutOptionals.replaceAll(matchInvertedNumericAndPlus, '');
  }

  int getIndexAfterLastOf(Pattern pattern) {
    return this.lastIndexOf(pattern) + 1;
  }

  String encodeBase64() {
    if (this == null) {
      return null;
    }
    final bytes = utf8.encode(this);
    final base64 = base64Url.encode(bytes);

    return base64;
  }

  List<String> textSplit() {
    return this.split(matchWhiteSpace);
  }
}

extension Check on String {
  static final Pattern _matchProtocol = "://";
  static final RegExp _matchEmail = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  bool isNullOrEmpty() => this == null || this.isEmpty;

  bool get isEmail {
    return _matchEmail.hasMatch(this);
  }

  bool get isPort {
    if (this.isEmpty) {
      return true;
    }
    final int port = int.tryParse(this);
    if (port == null || port < 1 || port >= 65535) {
      return false;
    }
    return true;
  }

  bool get containsProtocol {
    return this.contains(_matchProtocol);
  }
}

extension StringConversion on String {
  int get intValue => int.parse(this);
}
