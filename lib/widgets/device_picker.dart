// @dart=2.9

import 'dart:async';

import 'package:dart_chromecast/casting/cast_device.dart';
import 'package:dart_chromecast/chromecast.dart';
import 'package:flutter/material.dart';

class ChromeCastDevicePickerText {
  final String chooseDevice;
  final String connecting;
  final String cancel;

  const ChromeCastDevicePickerText(
      {this.chooseDevice = "Choose device",
      this.connecting = "Connecting",
      this.cancel = "Cancel"});
}

class ChromeCastDevicePicker extends StatefulWidget {
  final ChromeCastDevicePickerText text;

  const ChromeCastDevicePicker({this.text = const ChromeCastDevicePickerText()});

  @override
  _ChromeCastDevicePickerState createState() {
    return _ChromeCastDevicePickerState();
  }
}

class _ChromeCastDevicePickerState extends State<ChromeCastDevicePicker> {
  final List<CastDevice> _devices = [];
  bool isReady = true;

  @override
  void initState() {
    super.initState();
    ChromeCastInfo().setCallbackOnConnect(() => Navigator.pop(context, true));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(isReady ? widget.text.chooseDevice : widget.text.connecting),
        content: isReady
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (_, int index) {
                  return CastDeviceTile(_devices[index], () {
                    _pickDevice(_devices[index]);
                  });
                }),
        contentPadding: const EdgeInsets.fromLTRB(8, 20.0, 8, 0),
        actions: <Widget>[
          if (isReady)
            TextButton(
                child: Text(widget.text.cancel,
                    style: TextStyle(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.pop(context, false);
                })
        ]);
  }

  Future<void> _pickDevice(CastDevice device) async {
    setState(() {
      isReady = false;
    });
    await ChromeCastInfo().onDevicePicked(device);
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
    return ListTile(
        title: Text(widget.device.friendlyName),
        onTap: null == ChromeCastInfo().onDevicePicked ? null : widget.onTap);
  }

  void _update() {
    setState(() {});
  }
}
