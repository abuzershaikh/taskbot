// File: custom_app_action_dialog.dart
 
import 'package:flutter/material.dart';
import 'clickable_outline.dart'; // Import the new file

class CustomAppActionDialog extends StatelessWidget {
  final Map<String, String> app;
  final Function(String actionName, Map<String, String> appDetails) onActionSelected;
  final Map<String, GlobalKey<ClickableOutlineState>> activeOutlineKeys; // Added field

  const CustomAppActionDialog({
    super.key,
    required this.app,
    required this.onActionSelected,
    required this.activeOutlineKeys, // Added constructor parameter
  });

  @override
  Widget build(BuildContext context) {
    print('CustomAppActionDialog: build method called for app: ${app['name']}');
    const double desiredDialogWidth = 180.0;

    // Helper to create and register a key for a ClickableOutline
    GlobalKey<ClickableOutlineState> _registerKey(String actionName, dynamic widget) {
      final keyName = "dialog_appaction_${actionName.toLowerCase().replaceAll(' ', '_')}";
      final key = GlobalKey<ClickableOutlineState>(debugLabel: keyName);
      // Add the key to the activeOutlineKeys map passed from PhoneMockupContainerState
      // This makes the key available for command execution.
      widget.activeOutlineKeys[keyName] = key;
      return key;
    }

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
                    _buildDialogOption(Icons.info_outline, 'App info', _registerKey('App info', this), () {
                      debugPrint('CustomAppActionDialog: "App info" option tapped.');
                      onActionSelected('App info', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.pause_circle_outline, 'Pause app', _registerKey('Pause app', this), () {
                      debugPrint('CustomAppActionDialog: "Pause app" option tapped.');
                      onActionSelected('Pause app', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.delete_outline, 'Uninstall', _registerKey('Uninstall', this), () {
                      debugPrint('CustomAppActionDialog: "Uninstall" option tapped.');
                      onActionSelected('Uninstall', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.share, 'Share', _registerKey('Share', this), () {
                      debugPrint('CustomAppActionDialog: "Share" option tapped.');
                      onActionSelected('Share', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.edit, 'Edit', _registerKey('Edit', this), () {
                      debugPrint('CustomAppActionDialog: "Edit" option tapped.');
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

  Widget _buildDialogOption(IconData icon, String text, GlobalKey<ClickableOutlineState> key, VoidCallback onTap) {
    return ClickableOutline(
      key: key, // Assign key
      onTap: onTap,
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