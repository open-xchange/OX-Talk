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

import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url/url.dart';

extension UrlPreview on String {
  // RegEx is taken from here: https://www.w3resource.com/javascript-exercises/javascript-regexp-exercise-9.php
  static final _matchContainsUrl = RegExp(
      r'(?:(?:https?|ftps?):\/\/)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/\S*)?');

  static Url _previewUrl;

  Url get previewUrl {
    return _previewUrl;
  }

  set previewUrl(Url newValue) {
    _previewUrl = newValue;
  }

  Future<bool> get hasPreviewableUrl async {
    if (this._containsUrls) {
      Metadata metadata = await this.previewUrl.previewMetaData;
      return metadata.image == null ? false : true;
    }
    return false;
  }

  bool get _containsUrls {
    final List<Url> urls = _matchContainsUrl
        .allMatches(this)
        .map((match) => Url.parse(match.group(0).trim()))
        .toList();

    if (urls.length > 0) {
      this.previewUrl = urls.first;
      return true;
    } else {
      return false;
    }
  }
}

extension PreviewMetaData on Url {
  static Metadata _previewMetaData;

  Future<Metadata> get previewMetaData async {
    if (_previewMetaData != null) {
      return _previewMetaData;
    }

    final response = await http.get(this.toString());
    final document = responseToDocument(response);
    final metaData = MetadataParser.parse(document);

    _previewMetaData.title = metaData.title;
    _previewMetaData.description = metaData.description;
    _previewMetaData.image = metaData.image;
    _previewMetaData.url = metaData.url;

    return _previewMetaData;
  }
}
