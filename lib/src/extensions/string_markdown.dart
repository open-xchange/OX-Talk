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

import 'package:html2md/html2md.dart' as html2md;

extension Markdown on String {
  static final RegExp _matchContainsEmail = RegExp(
      r'(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))');

  List<String> emailAddresses() {
    final addresses = _matchContainsEmail.allMatches(this).map((match) => match.group(0)).toList();
    return addresses.length > 0 ? addresses : null;
  }

  String get markdownValue {
    final _emailAddresses = emailAddresses();
    String markdown = this;

    // NOTE: The MarkDownBody() escapes some characters with '\'. So, this
    // replaces all matching '\' backslashes, except those who are from a '\n'.
    final Pattern search = "\\";
    markdown = html2md.convert(markdown).replaceAll(search, "");

    _emailAddresses?.forEach((address) {
      markdown = markdown.replaceAll(address, "[$address](mailto:$address)").toString();
    });

    return markdown;
  }

  String stripMarkdown() {
    return this._stripMarkdownLinks()._stripStrongDelimiter()._stripUnderscoreDelimiter()._stripStrikeThroughDelimiter();
  }

  String _stripMarkdownLinks() {
    final match = RegExp(r'\[(.+?)\]\(([^ ]+)( "(.+?)")??\)');
    return this?.replaceAllMapped(match, (Match m) => '${m[1]}');
  }

  String _stripStrongDelimiter() {
    final match = RegExp(r'\*{1,2}([0-9a-zA-Z\w\.,;:-_"\!\?][^\*]+)\*{1,2}');
    return this?.replaceAllMapped(match, (Match m) => '${m[1]}');
  }

  String _stripUnderscoreDelimiter() {
    final match = RegExp(r'\_{1,2}([0-9a-zA-Z\w\.,;:-_"\!\?][^\_]+)\_{1,2}');
    return this?.replaceAllMapped(match, (Match m) => '${m[1]}');
  }

  String _stripStrikeThroughDelimiter() {
    final match = RegExp(r'\~{1,2}([0-9a-zA-Z\w\.,;:-_"\!\?][^\~]+)\~{1,2}');
    return this?.replaceAllMapped(match, (Match m) => '${m[1]}');
  }
}