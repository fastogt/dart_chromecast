// @dart=2.9

import 'package:flutter/material.dart';

class CCDisconnectDialogText {
  final String title;
  final String message;
  final String cancel;
  final String disconnect;

  const CCDisconnectDialogText(
      {this.title = "Disconnect",
      this.message = "Are you sure you want to disconnect and stop casting?",
      this.cancel = "Cancel",
      this.disconnect = "Disconnect"});
}

class CCDisconnectDialog extends StatelessWidget {
  final Color textColor;
  final CCDisconnectDialogText text;

  const CCDisconnectDialog({this.textColor, this.text = const CCDisconnectDialogText()});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(text.title),
        content: Text(text.message, softWrap: true),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        actions: <Widget>[
          TextButton(
              child: Text(text.cancel),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          ElevatedButton(
              child: Text(text.disconnect),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ]);
  }
}
