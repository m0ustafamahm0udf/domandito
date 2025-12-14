import 'dart:io';

import 'package:domandito/modules/security/services/security_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// A simple, respectful security warning screen shown when the device
/// is detected as rooted/jailbroken/emulator or running in debug mode.
class SecurityWarningScreen extends StatelessWidget {
  const SecurityWarningScreen({super.key, required this.status});

  final SecurityStatus status;

  String get _description {
    switch (status) {
      case SecurityStatus.rooted:
        return 'This device appears to be rooted. For security reasons, the app cannot run on rooted devices.';
      case SecurityStatus.jailbroken:
        return 'This device appears to be jailbroken. For security reasons, the app cannot run on jailbroken devices.';
      case SecurityStatus.isMockLocation:
        return 'This device has mock location enabled. For security reasons, the app cannot run with mock location enabled.';
      case SecurityStatus.emulator:
        return 'This looks like an emulator. The app may require a physical device to run securely.';
      case SecurityStatus.debugMode:
        return 'The app is running in debug mode. For security-sensitive features, please run a release build.';
      case SecurityStatus.developmentMode:
        return 'Development mode is enabled on this device. For security reasons, the app cannot run with development mode enabled.';
      case SecurityStatus.unknown:
        return 'We could not verify the device security. To protect your data, the app will not proceed.';
      case SecurityStatus.safe:
        return 'Device check passed.';
    }
  }

  IconData get _icon {
    switch (status) {
      case SecurityStatus.safe:
        return Icons.check_circle_outline;
      default:
        return Icons.block;
    }
  }

  Color _iconColor(BuildContext context) {
    switch (status) {
      case SecurityStatus.safe:
        return Colors.green;
      default:
        return Colors.red[900]!;
    }
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // disallow back navigation
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, size: 72, color: _iconColor(context)),
                  const SizedBox(height: 16),
                  Text(
                    'Security Warning',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_description, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _exitApp,

                    child: const Text(
                      'Exit App',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
