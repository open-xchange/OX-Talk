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

import 'dart:convert';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ox_coi/src/data/notification.dart';
import 'package:ox_coi/src/data/push_chat_message.dart';
import 'package:ox_coi/src/data/push_validation.dart';
import 'package:ox_coi/src/extensions/string_apis.dart';
import 'package:ox_coi/src/log/log_manager.dart';
import 'package:ox_coi/src/notifications/display_notification_manager.dart';
import 'package:ox_coi/src/platform/method_channels.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/push/push_bloc.dart';
import 'package:ox_coi/src/push/push_event_state.dart';
import 'package:ox_coi/src/security/security_manager.dart';

const loggerName = "push_manager";

Future<void> onBackgroundMessage(Map<String, dynamic> message) async {
  final logManager = LogManager();
  await logManager.setup(logToFile: true, logLevel: Level.INFO);
  final logger = Logger(loggerName);
  //TODO: Add functionality
  logger.info("onBackgroundMessage $message");
  return Future(null);
}

class PushManager {
  final _logger = Logger(loggerName);
  final _firebaseMessaging = FirebaseMessaging();
  final _notificationManager = DisplayNotificationManager();

  BuildContext _buildContext;
  PushBloc _pushBloc;

  static PushManager _instance;

  factory PushManager() => _instance ??= PushManager._internal();

  PushManager._internal();

  Future<void> setup(PushBloc pushBloc) async {
    this._pushBloc = pushBloc;
    //firebase setup
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _logger.info(message);
        final notificationData = NotificationData.fromJson(message);
        if (notificationData.valid) {
          final decryptedContent = await decryptAsync(notificationData.content);
          if (_isValidationPush(decryptedContent)) {
            final validation = _getPushValidation(decryptedContent).validation;
            _logger.info("Validation message with state validation: $validation received");
            _pushBloc.add(ValidateMetadata(validation: validation));
          } else {
            final pushChatMessage = _getPushChatMessage(decryptedContent);
            final fromEmail = pushChatMessage.fromEmail;
            final context = Context();
            print("dboehrs starting decrypt for content $pushChatMessage");

            var contentType = pushChatMessage.contentType;
            if (contentType.isNullOrEmpty()) {
              contentType = "text/plain; charset=utf-8";
              print("dboehrs manually setting content type to avoid null / empty value");
            }
            final body = await context.decryptInMemory(contentType, pushChatMessage.content, fromEmail);
            print("dboehrs decrypt done with result: $body");
            _logger.info("Chat message received from: $fromEmail");
            await _notificationManager.showNotificationFromPushAsync(fromEmail, body);
          }
        }
        return Future(null);
      },
      onResume: (Map<String, dynamic> message) {
        //TODO: Add functionality
        _logger.info("onResume $message");
        return Future(null);
      },
      onLaunch: (Map<String, dynamic> message) {
        //TODO: Add functionality
        _logger.info("onLaunch $message");
        return Future(null);
      },
      onBackgroundMessage: onBackgroundMessage,
    );
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  Future<String> getPushTokenAsync() async {
    return await _firebaseMessaging.getToken();
  }

  Future<String> getPushResourceAsync() async {
    return await getPreference(preferenceNotificationsPush);
  }

  Future<String> decryptAsync(String encryptedBase64Content) async {
    final privateKey = await getPushPrivateKeyAsync();
    final publicKey = await getPushPublicKeyAsync();
    final auth = await getPushAuthAsync();

    return await SecurityChannel.instance.invokeMethod(SecurityChannel.kMethodDecrypt, {
      SecurityChannel.kArgumentContent: encryptedBase64Content,
      SecurityChannel.kArgumentPrivateKey: privateKey,
      SecurityChannel.kArgumentPublicKey: publicKey,
      SecurityChannel.kArgumentAuth: auth,
    });
  }

  bool _isValidationPush(String decryptedContent) {
    final pushValidationMap = jsonDecode(decryptedContent);
    final pushValidation = PushValidation.fromJson(pushValidationMap);
    return !pushValidation.validation.isNullOrEmpty();
  }

  PushValidation _getPushValidation(String decryptedContent) {
    final pushValidationMap = jsonDecode(decryptedContent);
    return PushValidation.fromJson(pushValidationMap);
  }

  PushChatMessage _getPushChatMessage(String decryptedContent) {
    final pushValidationMap = jsonDecode(decryptedContent);
    return PushChatMessage.fromJson(pushValidationMap);
  }
}
