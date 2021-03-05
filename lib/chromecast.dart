import 'dart:async';

import 'package:dart_chromecast/casting/cast.dart';
import 'package:dart_chromecast/widgets/device_picker.dart';
import 'package:dart_chromecast/widgets/disconnect_dialog.dart';
import 'package:dart_chromecast/utils/mdns_find_chromecast.dart' as find;
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChromeCastInfo {
  static final ChromeCastInfo _instance = ChromeCastInfo._internal();

  CastSender? _castSender;
  final BehaviorSubject<List<CastDevice>> _foundServices = BehaviorSubject<List<CastDevice>>();
  final BehaviorSubject<bool> _connected = BehaviorSubject<bool>();

  factory ChromeCastInfo() {
    return _instance;
  }

  ChromeCastInfo._internal() {
    _connected.add(false);
    _foundServices.add([]);
    _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    final List<find.CastDevice> _found = await find.findChromecasts();
    final List<CastDevice> result = [];
    for (final find.CastDevice d in _found) {
      result.add(CastDevice(name: d.name, host: d.ip, port: d.port, type: '_googlecast._tcp'));
    }
    _foundServices.add(result);
  }

  void pickDeviceDialog(BuildContext context,
      {VoidCallback? onConnected,
      ChromeCastDevicePickerText translations = const ChromeCastDevicePickerText()}) {
    showDialog(
        context: context,
        builder: (context) {
          return ChromeCastDevicePicker(_foundServices.stream, text: translations);
        }).then((connected) {
      if (connected ?? false) {
        onConnected?.call();
      }
    });
  }

  void disconnectDialog(BuildContext context,
      {VoidCallback? onDisconnected,
      CCDisconnectDialogText translations = const CCDisconnectDialogText()}) {
    if (_connected.value!) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CCDisconnectDialog(text: translations);
          }).then((disconnected) {
        if (disconnected ?? false) {
          ChromeCastInfo().disconnect();
          onDisconnected?.call();
        }
      });
    }
  }

  void disconnect() async {
    if (_castSender != null) {
      _castSender!.disconnect();
      _castSender = null;
      _connected.add(false);
    }
  }

  Future<bool> connectToDevice(CastDevice device) {
    _castSender = CastSender(device);
    final StreamSubscription subscription =
        _castSender!.castSessionController.stream.listen((CastSession? castSession) {
      if (castSession!.isConnected) {
        _connected.add(true);
      }
    });

    return _castSender!.connect().then((connected) {
      if (!connected) {
        subscription.cancel();
        _castSender = null;
      }
      _castSender!.launch();
      return connected;
    });
  }

  CastSender? get castSender => _castSender;

  Stream<List<CastDevice>> get foundServices => _foundServices.stream;

  bool get castConnected => _connected.value!;

  Stream<bool> get castConnectedStream => _connected.stream;

  void play() {
    if (_castSender == null) {
      return;
    }
    _castSender!.play();
  }

  void pause() {
    if (_castSender == null) {
      return;
    }
    _castSender!.pause();
  }

  double? position() => _castSender?.castSession?.castMediaStatus?.position;

  bool serviceFound() => _foundServices.value?.isNotEmpty ?? false;

  void initVideo(String contentID, String title) {
    if (_castSender == null) {
      return;
    }
    final castMedia = CastMedia(contentId: contentID, title: title);
    _castSender!.load(castMedia);
  }

  void togglePlayPauseCC() {
    if (_castSender == null) {
      return;
    }

    isPlaying() ? castSender!.togglePause() : castSender!.play();
  }

  void setVolume(double volume) {
    if (_castSender == null) {
      return;
    }
    _castSender!.setVolume(volume);
  }

  bool isPlaying() {
    if (_castSender?.castSession?.castMediaStatus == null) {
      return false;
    }

    return _castSender!.castSession!.castMediaStatus!.isPlaying;
  }
}
