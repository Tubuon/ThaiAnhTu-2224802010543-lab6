import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    var status = await Permission.storage.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.storage.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<bool> requestAudioPermission() async {
    if (kIsWeb) return true;

    if (await Permission.audio.isGranted) return true;

    var status = await Permission.audio.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<bool> hasPermissions() async {
    if (kIsWeb) return true;

    bool storagePermission = await Permission.storage.isGranted;
    bool audioPermission = await Permission.audio.isGranted;
    return storagePermission || audioPermission;
  }
}