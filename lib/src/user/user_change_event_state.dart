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

import 'package:meta/meta.dart';
import 'package:ox_coi/src/data/config.dart';

abstract class UserChangeEvent {}

class RequestUser extends UserChangeEvent {}

class UserLoaded extends UserChangeEvent {
  final Config config;

  UserLoaded({@required this.config});
}

class ChangesApplied extends UserChangeEvent {}

class UserPersonalDataChanged extends UserChangeEvent {
  final String username;
  final String avatarPath;

  UserPersonalDataChanged({@required this.username, @required this.avatarPath});
}

class UserSignatureChanged extends UserChangeEvent {
  final String signature;

  UserSignatureChanged({@required this.signature});
}

class UserAvatarChanged extends UserChangeEvent {
  final String avatarPath;

  UserAvatarChanged({@required this.avatarPath});
}

class UserAccountDataChanged extends UserChangeEvent {
  final String imapLogin;
  final String imapPassword;
  final String imapServer;
  final String imapPort;
  final int imapSecurity;
  final String smtpLogin;
  final String smtpPassword;
  final String smtpServer;
  final String smtpPort;
  final int smtpSecurity;

  UserAccountDataChanged({
    @required this.imapLogin,
    @required this.imapPassword,
    @required this.imapServer,
    @required this.imapPort,
    @required this.imapSecurity,
    @required this.smtpLogin,
    @required this.smtpPassword,
    @required this.smtpServer,
    @required this.smtpPort,
    @required this.smtpSecurity,
  });
}

abstract class UserChangeState {}

class UserChangeStateInitial extends UserChangeState {}

class UserChangeStateLoading extends UserChangeState {}

class UserChangeStateSuccess extends UserChangeState {
  final Config config;

  UserChangeStateSuccess({@required this.config});
}

class UserChangeStateFailure extends UserChangeState {
  String error;

  UserChangeStateFailure({@required this.error});
}

class UserChangeStateApplied extends UserChangeState {}
