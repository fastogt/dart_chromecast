import 'dart:async';

import 'package:dart_chromecast/casting/cast_device.dart';
import 'package:dart_chromecast/chromecast.dart';
import 'package:flutter/material.dart';

class ChromeCastDevicePickerText {
  final String broadcast;
  final String chooseDevice;
  final String connecting;
  final String cancel;

  const ChromeCastDevicePickerText({
      this.broadcast = "Broadcast on",
      this.chooseDevice = "Choose device",
      this.connecting = "Connecting",
      this.cancel = "Cancel"
  });
}

class ChromeCastDevicePicker extends StatelessWidget {
  final Stream<List<CastDevice>> devices;
  final ChromeCastDevicePickerText text;

  const ChromeCastDevicePicker(this.devices, {this.text = const ChromeCastDevicePickerText()});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        title: Column(children: [
          Text(text.broadcast, style: const TextStyle(fontSize: 25)),
          const Divider(thickness: 1),
          const SizedBox(height: 30),
          Text(text.chooseDevice, style: const TextStyle(fontSize: 15)),
        ]),
        content: _devices(),
        contentPadding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
        actionsPadding: const EdgeInsets.only(top: 5.0),
        actions: <Widget>[
          TextButton(
              child: Text(text.cancel,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              onPressed: () {
                Navigator.pop(context, false);
              })
        ]);
  }

  Widget _devices() {
    return StreamBuilder<List<CastDevice>>(
        initialData: const [],
        stream: devices,
        builder: (context, snapshot) {
          final List<CastDevice> devices = snapshot.data!;
          if (devices.isNotEmpty) {
            return SingleChildScrollView(
                child: Column(
                    children: List<CastDeviceTile>.generate(devices.length, (int index) {
              return CastDeviceTile(devices[index], () {
                ChromeCastInfo().connectToDevice(devices[index]).then((value) {
                  Navigator.pop(context, value);
                });
              });
            })));
          }
          return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
        });
  }
}

class CastDeviceTile extends StatefulWidget {
  final CastDevice device;
  final VoidCallback onTap;

  const CastDeviceTile(this.device, this.onTap);

  @override
  _CastDeviceTileState createState() => _CastDeviceTileState();
}

class _CastDeviceTileState extends State<CastDeviceTile> {
  @override
  void initState() {
    super.initState();
    widget.device.addListener(_update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.device.removeListener(_update);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
          leading: Container(height: double.infinity, child: const Icon(Icons.tv_outlined)),
          title: Text(widget.device.friendlyName ?? 'Unknown'),
          subtitle: Text('${castDeviceTypeToText(widget.device.deviceType)}'),
          onTap: widget.onTap
      ),
    );
  }

  void _update() {
    setState(() {});
  }
}
