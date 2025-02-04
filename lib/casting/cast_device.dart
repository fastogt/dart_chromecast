import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

enum CastDeviceType {
  Unknown,
  ChromeCast,
  AppleTV,
}

enum GoogleCastModelType {
  GoogleHub,
  GoogleHome,
  GoogleMini,
  GoogleMax,
  ChromeCast,
  ChromeCastAudio,
  NonGoogle,
  CastGroup,
}

String castDeviceTypeToText(CastDeviceType cast) {
  if (cast == CastDeviceType.ChromeCast) {
    return 'ChromeCast';
  } else if (cast == CastDeviceType.AppleTV) {
    return 'AppleTV';
  }
  return 'Unknown';
}

class CastDevice extends ChangeNotifier {
  final String? name;
  final String? type;
  final String? host;
  final int? port;

  /// Contains the information about the device.
  /// You can decode with utf8 a bunch of information
  ///
  /// * md - Model Name (e.g. "Chromecast");
  /// * id - UUID without hyphens of the particular device (e.g. xx12x3x456xx789xx01xx234x56789x0);
  /// * fn - Friendly Name of the device (e.g. "Living Room");
  /// * rs - Unknown (recent share???) (e.g. "Youtube TV");
  /// * bs - Unknown (e.g. "XX1XXX2X3456");
  /// * st - Unknown (e.g. "1");
  /// * ca - Unknown (e.g. "1234");
  /// * ic - Icon path (e.g. "/setup/icon.png");
  /// * ve - Version (e.g. "04").
  final Map<String, Uint8List>? attr;

  String? _friendlyName;
  String? _modelName;

  CastDevice({
    this.name,
    this.type,
    this.host,
    this.port,
    this.attr,
  }) {
    initDeviceInfo();
  }

  void initDeviceInfo() async {
    if (CastDeviceType.ChromeCast == deviceType) {
      if (null != attr && null != attr!['fn']) {
        _friendlyName = utf8.decode(attr!['fn']!);
        if (null != attr!['md']) {
          _modelName = utf8.decode(attr!['md']!);
        }
      } else {
        // Attributes are not guaranteed to be set, if not set fetch them via the eureka_info url
        // Possible parameters: version,audio,name,build_info,detail,device_info,net,wifi,setup,settings,opt_in,opencast,multizone,proxy,night_mode_params,user_eq,room_equalizer
        try {
          const bool trustSelfSigned = true;
          final HttpClient httpClient = HttpClient()
            ..badCertificateCallback =
                ((X509Certificate cert, String host, int port) => trustSelfSigned);
          final IOClient ioClient = IOClient(httpClient);
          final http.Response response = await ioClient
              .get(Uri.parse('https://$host:8443/setup/eureka_info?params=name,device_info'));
          final Map deviceInfo = jsonDecode(response.body);

          if (deviceInfo['name'] != null && deviceInfo['name'] != 'Unknown') {
            _friendlyName = deviceInfo['name'];
          } else if (deviceInfo['ssid'] != null) {
            _friendlyName = deviceInfo['ssid'];
          }

          if (deviceInfo['model_name'] != null) {
            _modelName = deviceInfo['model_name'];
          }
        } catch (exception) {
          log(exception.toString());
        }
      }
    }
    notifyListeners();
  }

  CastDeviceType get deviceType {
    if (type!.contains('_googlecast._tcp')) {
      return CastDeviceType.ChromeCast;
    } else if (type!.contains('_airplay._tcp')) {
      return CastDeviceType.AppleTV;
    }
    return CastDeviceType.Unknown;
  }

  String? get friendlyName {
    if (null != _friendlyName) {
      return _friendlyName;
    }
    return name;
  }

  String? get modelName => _modelName;

  GoogleCastModelType get googleModelType {
    switch (modelName) {
      case "Google Home":
        return GoogleCastModelType.GoogleHome;
      case "Google Home Hub":
        return GoogleCastModelType.GoogleHub;
      case "Google Home Mini":
        return GoogleCastModelType.GoogleMini;
      case "Google Home Max":
        return GoogleCastModelType.GoogleMax;
      case "Chromecast":
        return GoogleCastModelType.ChromeCast;
      case "Chromecast Audio":
        return GoogleCastModelType.ChromeCastAudio;
      case "Google Cast Group":
        return GoogleCastModelType.CastGroup;
      default:
        return GoogleCastModelType.NonGoogle;
    }
  }
}
