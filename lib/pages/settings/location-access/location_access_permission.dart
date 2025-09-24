// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';

class LocationAccessPermission extends StatefulWidget {
  const LocationAccessPermission({super.key});

  @override
  State<LocationAccessPermission> createState() =>
      _LocationAccessPermissionState();
}

class _LocationAccessPermissionState extends State<LocationAccessPermission> {
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionStatus();
  }

  Future<void> _checkLocationPermissionStatus() async {
    // PermissionStatus status = await Permission.location.status;
    // setState(() {
    //   _locationPermissionGranted = status == PermissionStatus.granted;
    // });
  }

  Future<void> _requestLocationPermission() async {
    // PermissionStatus status = await Permission.location.request();
    // setState(() {
    //   _locationPermissionGranted = status == PermissionStatus.granted;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: const Text('Location Access'),
      trailing: Checkbox(
        value: _locationPermissionGranted,
        onChanged: (value) {
          if (value == true) {
            // If the checkbox is unchecked, request the location permission.
            _requestLocationPermission();
          } else {
            setState(() {
              _locationPermissionGranted = false;
            });
            // You can handle what to do when the checkbox is checked, if needed.
          }
        },
      ),
    );
  }
}

/*
class LocationAccessPermission extends StatelessWidget {
  const LocationAccessPermission({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Location access'),
      trailing: Checkbox(onChanged: (val){}, value: false),
    );
  }
}
*/
