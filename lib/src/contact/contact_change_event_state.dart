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
import 'package:ox_coi/src/contact/contact_change.dart';

import 'contact_change_bloc.dart';

abstract class ContactChangeEvent {}

class ChangeContact extends ContactChangeEvent {
  final String name;
  final String email;
  final ContactAction contactAction;

  ChangeContact({
    @required this.name,
    @required this.email,
    @required this.contactAction,
  });
}

class DeleteContact extends ContactChangeEvent {
  final int id;

  DeleteContact({@required this.id});
}

class ContactAdded extends ContactChangeEvent {
  final int id;

  ContactAdded({@required this.id});
}

class ContactEdited extends ContactChangeEvent {}

class ContactDeleted extends ContactChangeEvent {}

class ContactDeleteFailed extends ContactChangeEvent {
  final int contactId;
  final String error;

  ContactDeleteFailed({@required this.contactId, @required this.error});
}

class BlockContact extends ContactChangeEvent {
  final int contactId;
  final int chatId;
  final int messageId;

  BlockContact({this.chatId, this.contactId, this.messageId});
}

class ContactBlocked extends ContactChangeEvent {
  final int contactId;

  ContactBlocked({@required this.contactId});
}

class UnblockContact extends ContactChangeEvent {
  final int id;

  UnblockContact({@required this.id});
}

class ContactUnblocked extends ContactChangeEvent {}

abstract class ContactChangeState {}

class ContactChangeStateInitial extends ContactChangeState {}

class ContactChangeStateLoading extends ContactChangeState {}

class ContactChangeStateSuccess extends ContactChangeState {
  final int id;
  final ContactChangeType type;

  ContactChangeStateSuccess({@required this.type, this.id});
}

class ContactChangeStateFailure extends ContactChangeState {
  final int contactId;
  final String error;

  ContactChangeStateFailure({this.contactId, @required this.error});
}
