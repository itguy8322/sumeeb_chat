import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

class MicrophoneAccessPermission extends StatefulWidget {
  const MicrophoneAccessPermission({super.key});

  @override
  State<MicrophoneAccessPermission> createState() =>
      _MicrophoneAccessPermissionState();
}

class _MicrophoneAccessPermissionState
    extends State<MicrophoneAccessPermission> {
  bool _microphonePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkMicrophonePermissionStatus();
  }

  Future<void> _checkMicrophonePermissionStatus() async {
    // PermissionStatus status = await Permission.microphone.status;
    // setState(() {
    //   _microphonePermissionGranted = status == PermissionStatus.granted;
    // });
  }

  Future<void> _requestMicrophonePermission() async {
    // PermissionStatus status = await Permission.microphone.request();
    // setState(() {
    //   _microphonePermissionGranted = status == PermissionStatus.granted;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mic),
      title: const Text('Microphone access'),
      trailing: Checkbox(
        value: _microphonePermissionGranted,
        onChanged: (value) {
          if (value == true) {
            // If the checkbox is unchecked, request the microphone permission.
            _requestMicrophonePermission();
          } else {
            // You can handle what to do when the checkbox is checked, if needed.
            setState(() {
              _microphonePermissionGranted = false;
            });
          }
        },
      ),
    );
  }
}

/*
class MicrophoneAccessPermission extends StatelessWidget {
  const MicrophoneAccessPermission({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return (
      builder: (context) {
        return ListTile(
          title: const Text('Microphone access'),
          trailing: Checkbox(onChanged: (val){}, value: false),
        );
      }
    );
  }
}
*/
