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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/chat/chat_composer_bloc.dart';
import 'package:ox_coi/src/chat/chat_composer_event_state.dart';
import 'package:ox_coi/src/ui/custom_theme.dart';
import 'package:ox_coi/src/widgets/custom_painters.dart';

class AudioPlayback extends StatefulWidget {
  final List<double> dbPeakList;
  final int replayTime;

  AudioPlayback({@required this.dbPeakList, @required this.replayTime});

  @override
  _AudioPlaybackState createState() => _AudioPlaybackState();
}

class _AudioPlaybackState extends State<AudioPlayback> {
  int _dragUpdateValue = 0;
  var _replayFactor = 1.0;
  var _replayTime;
  var _peakListLength;

  @override
  void initState() {
    super.initState();
    _replayFactor = 1.0;
    _replayTime = 0;
    _dragUpdateValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var changeableList = List<double>();

        changeableList.addAll(widget.dbPeakList);
        _peakListLength = changeableList.length;

        var spaceNeeded = (_peakListLength * 3);
        if (spaceNeeded > constraints.maxWidth) {
          var start = ((_peakListLength - (((_peakListLength - constraints.maxWidth)).round())) / 3).round();
          changeableList.removeRange(start, widget.dbPeakList.length);
          _replayFactor = (widget.dbPeakList.length / changeableList.length);
        }

        _replayTime = (widget.replayTime / _replayFactor).round();
        if (_replayTime > changeableList.length) {
          _replayTime--;
        }

        return Container(
          padding: const EdgeInsets.only(top: 30.0),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTapUp: _onTapUp,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: <Widget>[
                VoicePainter(
                  dbPeakList: changeableList,
                  color: CustomTheme.of(context).onSurface,
                  withChild: true,
                  width: constraints.maxWidth,
                ),
                VoicePainter(
                  dbPeakList: changeableList.getRange(0, _replayTime).toList(),
                  color: CustomTheme.of(context).accent,
                  withChild: false,
                  width: constraints.maxWidth,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragUpdateValue = (details.localPosition.dx / 2).round();
    final listLength = widget.dbPeakList.length;

    if (_dragUpdateValue >= 0 && _dragUpdateValue <= listLength) {
      BlocProvider.of<ChatComposerBloc>(context)?.add(UpdateReplayTime(replayTime: _dragUpdateValue));
    } else if (_dragUpdateValue > listLength) {
      BlocProvider.of<ChatComposerBloc>(context)?.add(UpdateReplayTime(replayTime: listLength));
    } else if (_dragUpdateValue <= 0) {
      BlocProvider.of<ChatComposerBloc>(context)?.add(UpdateReplayTime(replayTime: 0));
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _seekToPosition(_dragUpdateValue);
  }

  void _onTapUp(TapUpDetails details) {
    final x = (details.localPosition.dx / 2).round();

    _seekToPosition(x);
  }

  _seekToPosition(int position) {
    final listLength = widget.dbPeakList.length;
    if (position >= 0 && position <= listLength) {
      BlocProvider.of<ChatComposerBloc>(context)?.add(ReplayAudioSeek(seekValue: position));
    } else if (position > listLength) {
      BlocProvider.of<ChatComposerBloc>(context)?.add(ReplayAudioSeek(seekValue: listLength));
    } else if (position <= 0) {
      BlocProvider.of<ChatComposerBloc>(context)?.add(ReplayAudioSeek(seekValue: 0));
    }
  }
}

class VoicePainter extends StatefulWidget {
  final List<double> dbPeakList;
  final Color color;
  final bool withChild;
  final double width;

  VoicePainter({@required this.dbPeakList, @required this.color, @required this.withChild, @required this.width});

  @override
  _VoicePainterState createState() => _VoicePainterState();
}

class _VoicePainterState extends State<VoicePainter> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: widget.withChild
          ? Container(
              width: widget.width,
              child: CustomPaint(
                painter: HorizontalLinePainter(color: widget.color),
              ),
            )
          : Container(),
      size: Size(widget.width, 0.0),
      painter: BarPainter(peakLevel: widget.dbPeakList, callback: callback, color: widget.color),
    );
  }

  callback(bool removeFirstEntry, int cutoffValue) {
    BlocProvider.of<ChatComposerBloc>(context)?.add(RemoveFirstAudioDBPeak(removeFirstEntry: removeFirstEntry, cutoffValue: cutoffValue));
  }
}
