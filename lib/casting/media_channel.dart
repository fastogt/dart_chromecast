import 'dart:io';

import 'package:dart_chromecast/casting/cast_channel.dart';

class MediaChannel extends CastChannel {
  MediaChannel.create({Socket? socket, String? sourceId, String? destinationId})
      : super.createWithSocket(socket,
            sourceId: sourceId,
            destinationId: destinationId,
            namespace: 'urn:x-cast:com.google.cast.media');
}
