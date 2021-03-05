// @dart=2.9

import 'dart:async';

import 'package:dart_chromecast/casting/cast.dart';
import 'package:dart_chromecast/widgets/device_picker.dart';
import 'package:dart_chromecast/widgets/disconnect_dialog.dart';
import 'package:dart_chromecast/utils/mdns_find_chromecast.dart' as find;
import 'package:flutter/material.dart';

class ChromeCastInfo {
  static const int DISCOVERY_TIME_SEC = 3;
  static final ChromeCastInfo _instance = ChromeCastInfo._internal();

  CastSender _castSender;
  bool _castConnected;
  Function _callbackOnConnected;
  List<CastDevice> _foundServices = [];

  factory ChromeCastInfo() {
    return _instance;
  }

  ChromeCastInfo._internal() {
    _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    _foundServices = [];
    final List<find.CastDevice> _found = await find.findChromecasts();
    for (final find.CastDevice d in _found) {
      _foundServices
          .add(CastDevice(name: d.name, host: d.ip, port: d.port, type: '_googlecast._tcp'));
    }
  }

  void pickDeviceDialog(BuildContext context,
      {void Function() onConnected,
      ChromeCastDevicePickerText translations = const ChromeCastDevicePickerText()}) {
    showDialog(
        context: context,
        builder: (context) {
          return ChromeCastDevicePicker(text: translations);
        }).then((connected) {
      if (connected ?? false) {
        onConnected?.call();
      }
    });
  }

  void disconnectDialog(BuildContext context,
      {void Function() onDisconnected,
      CCDisconnectDialogText translations = const CCDisconnectDialogText()}) {
    if (ChromeCastInfo().castConnected) {
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
      _castSender.disconnect();
      _castSender = null;
      _castConnected = false;
    }
  }

  void _castSessionIsConnected(CastSession castSession) {
    _castConnected = true;
    _callbackOnConnected?.call();
  }

  Future<bool> _connectToDevice(CastDevice device) {
    _castSender = CastSender(device);
    final StreamSubscription subscription =
        _castSender.castSessionController.stream.listen((CastSession castSession) {
      if (castSession.isConnected) {
        _castSessionIsConnected(castSession);
      }
    });

    return _castSender.connect().then((connected) {
      if (!connected) {
        subscription.cancel();
        _castSender = null;
      }
      _castSender.launch();
      return connected;
    });
  }

  CastSender get castSender => _castSender;

  List<CastDevice> get foundServices => _foundServices;

  Future Function(CastDevice) get onDevicePicked => _connectToDevice;

  bool get castConnected => _castConnected ?? false;

  void play() => _castSender.play();

  void pause() => _castSender.pause();

  double position() => _castSender.castSession?.castMediaStatus?.position;

  bool serviceFound() => _foundServices.isNotEmpty;

  void initVideo(String contentID, String title) {
    final castMedia = CastMedia(
      contentId: contentID,
      title: title,
    );
    _castSender.load(castMedia);
  }

  void setCallbackOnConnect(Function callback) {
    _callbackOnConnected = callback;
  }

  void togglePlayPauseCC() {
    if (_castSender == null) {
      return;
    }

    isPlaying() ? castSender.togglePause() : castSender.play();
  }

  void setVolume(double volume) {
    if (_castSender == null) {
      return;
    }
    _castSender.setVolume(volume);
  }

  bool isPlaying() {
    if (_castSender == null ||
        _castSender.castSession == null ||
        _castSender.castSession.castMediaStatus == null) {
      return false;
    }

    return _castSender.castSession.castMediaStatus.isPlaying;
  }
}
