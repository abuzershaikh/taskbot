// File: custom_app_action_dialog.dart
 
import 'package:flutter/material.dart';
// Removed: import 'clickable_outline.dart'; 

class CustomAppActionDialog extends StatelessWidget {
  final Map<String, String> app;
  final Function(String actionName, Map<String, String> appDetails) onActionSelected;

  const CustomAppActionDialog({
    super.key,
    required this.app,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // print('CustomAppActionDialog: build method called for app: ${app['name']}');
    const double desiredDialogWidth = 180.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                app['icon']!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              app['name']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              width: desiredDialogWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogOption(Icons.info_outline, 'App info', () {
                      // print('CustomAppActionDialog: "App info" option tapped.');
                      onActionSelected('App info', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.pause_circle_outline, 'Pause app', () {
                      // print('CustomAppActionDialog: "Pause app" option tapped.');
                      onActionSelected('Pause app', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.delete_outline, 'Uninstall', () {
                      // print('CustomAppActionDialog: "Uninstall" option tapped.');
                      onActionSelected('Uninstall', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.share, 'Share', () {
                      // print('CustomAppActionDialog: "Share" option tapped.');
                      onActionSelected('Share', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.edit, 'Edit', () {
                      // print('CustomAppActionDialog: "Edit" option tapped.');
                      onActionSelected('Edit', app);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector( // Replaced ClickableOutline
      onTap: onTap,
      // Ensure the GestureDetector itself is recognized in hit tests for the full area
      // behavior: HitTestBehavior.opaque, // Uncomment if taps are not registering on the whole area
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}