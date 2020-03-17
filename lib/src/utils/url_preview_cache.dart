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

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:ox_coi/src/extensions/url_apis.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url/url.dart';

///
/// Precaching URL metadata.
///
/// How does the URL preview cache work?
///
/// Once the app has been launched, it will buffer all existent metadata of
/// URL's posted in a chat. URL preview metadata are encapsulated in [Metadata]
/// objects, which are serialized in JSONformat. Every [Metadata] object has its
/// own cache file. The filename contains informations about the belonging URL
/// the metadata has been cached for.
///
/// Example of a [Metadata] object cache file:
///
/// 286795806734.meta
///      |
///      +--> Hash-Code of cached URL (by calling [String.hashCode]
///
/// When the app has been launched, all cache files are read, deserialized from
/// JSON into a [Metadata] object and cached in the [_buffer] map. The key of
/// each map item is the hashCode of its URL string.
///
/// The directory of the cache is computed in [_getCacheDirPath] using the
/// [getLibraryDirectory] strategy of the path provider plugin, suffixed by
/// the string constant [_cacheDirName]. The [getLibraryDirectory] call produces
/// a platform dependent result.
///

class UrlPreviewCache {
  static const _cacheDirName = "UrlPreviewCache";
  static const _cacheFileExtension = "meta";
  static const _maxNumberOfCacheItems = 666;
  static const _maxOfOldestFilesToDelete = 23;
  SplayTreeMap<int, Metadata> _buffer;

  static final UrlPreviewCache _instance = UrlPreviewCache._init();

  factory UrlPreviewCache() {
    return _instance;
  }

  UrlPreviewCache._init() {
    _buffer = SplayTreeMap<int, Metadata>();
  }

  // Public API

  Future<void> prepareCache() async {
    final cachePath = await _getCacheDirPath();
    debugPrint("** Cache Path: $cachePath");
    Directory(cachePath).list().listen((entity) async {
      final cacheFile = File(entity.path);
      final metadata = await _getMetadataFor(file: cacheFile);
      final key = path.basenameWithoutExtension(cacheFile.path).intValue;
      _buffer[key] = metadata;
    });
  }

  int get numberOfCachedItems => _buffer.length;

  Future<int> get sizeOfCacheInBytes async {
    int size = 0;
    final cachePath = await _getCacheDirPath();
    Directory(cachePath).list().listen((FileSystemEntity item) async {
      final stat = await item.stat();
      size += stat.size;
    });
    return size;
  }

  Future<void> saveMetadataIfNeededFor({@required Url url}) async {
    if (url == null || url.toString().isEmpty == true) {
      return;
    }

    final key = url.toString().hashCode;

    // Do we have it buffered already?
    // (Note: If it's buffered, we have a cache file, too!)
    final bufferData = _buffer[key];
    if (bufferData != null) {
      return;
    }

    final metadata = await url.metaData;
    if (metadata == null || metadata.hasAllMetadata == false) {
      return;
    }

    _buffer[key] = metadata;

    final cacheFile = await _getCacheFileFor(url: url);
    await cacheFile.create(recursive: true);
    final json = jsonEncode(metadata);
    await cacheFile.writeAsString(json);

    _cleanUpIfNeeded();
  }

  Future<Metadata> getMetadataFor({@required Url url}) async {
    if (url == null || url.toString().isEmpty == true) {
      return null;
    }

    final key = url.toString().hashCode;
    return _buffer[key];
  }

  // Private Helper

  Future<String> _getCacheDirPath() async {
    final applicationSupportDirectory = await getTemporaryDirectory();
    return path.join(applicationSupportDirectory.path, _cacheDirName);
  }

  Future<File> _getCacheFileFor({@required Url url}) async {
    final cachePath = await _getCacheDirPath();
    final hash = url.toString().hashCode;
    final cacheFilePath = path.join(cachePath, "$hash.$_cacheFileExtension");

    return File(cacheFilePath);
  }

  Future<Metadata> _getMetadataFor({@required File file}) async {
    final fileExists = await file.exists();
    if (!fileExists) {
      return null;
    }

    final jsonString = await file.readAsString();
    final metadata = Metadata.fromJson(jsonDecode(jsonString));
    return metadata;
  }

  Future<void> _cleanUpIfNeeded() async {
    if (numberOfCachedItems <= _maxNumberOfCacheItems) {
      return;
    }

    final cachePath = await _getCacheDirPath();
    final fileList = Directory(cachePath).listSync();
    fileList.sort((a, b) => a.statSync().changed.millisecondsSinceEpoch.compareTo(b.statSync().changed.millisecondsSinceEpoch));
    final oldestFiles = fileList.sublist(0, _maxOfOldestFilesToDelete-1);

    oldestFiles.forEach((file) {
      final key = path.basenameWithoutExtension(file.path).intValue;
      file.deleteSync();
      _buffer.remove(key);
    });
  }
}
