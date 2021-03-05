import 'dart:core';

import 'package:dart_chromecast/casting/cast.dart';
import 'package:dart_chromecast/chromecast.dart';
import 'package:flutter/material.dart';

class ChromeCastIcon extends StatelessWidget {
  final void Function(bool connected)? onChromeCast;

  const ChromeCastIcon({this.onChromeCast});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CastDevice>>(
        initialData: const [],
        stream: ChromeCastInfo().foundServices,
        builder: (context, snapshot) {
          final List<CastDevice> devices = snapshot.data!;
          if (devices.isEmpty) {
            return const SizedBox();
          }

          return StreamBuilder<bool>(
              initialData: false,
              stream: ChromeCastInfo().castConnectedStream,
              builder: (context, snapshot) {
                if (snapshot.data!) {
                  return IconButton(
                      icon: const Icon(Icons.cast_connected),
                      onPressed: () {
                        ChromeCastInfo().disconnectDialog(context, onDisconnected: () {
                          onChromeCast?.call(false);
                        });
                      });
                } else {
                  return IconButton(
                      icon: const Icon(Icons.cast),
                      onPressed: () {
                        ChromeCastInfo().pickDeviceDialog(context, onConnected: () {
                          onChromeCast?.call(true);
                        });
                      });
                }
              });
        });
  }
}
