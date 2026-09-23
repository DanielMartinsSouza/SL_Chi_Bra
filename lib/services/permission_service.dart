import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }
}
