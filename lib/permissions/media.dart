import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

enum MediaPermissionStatus { granted, denied, permanentlyDenied, restricted }

class MediaPermissionsHandler {
  Future<bool> get isGranted async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.photos.status;
    } else if (Platform.isAndroid) {
      status = await Permission.storage.status;
    } else {
      return false;
    }

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return false;
      default:
        return false;
    }
  }

  Future<MediaPermissionStatus> request() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else if (Platform.isAndroid) {
      status = await Permission.storage.request();
    } else {
      return MediaPermissionStatus.denied;
    }

    switch (status) {
      case PermissionStatus.granted:
        return MediaPermissionStatus.granted;
      case PermissionStatus.denied:
        return MediaPermissionStatus.denied;
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return MediaPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return MediaPermissionStatus.restricted;
      default:
        return MediaPermissionStatus.denied;
    }
  }
}
