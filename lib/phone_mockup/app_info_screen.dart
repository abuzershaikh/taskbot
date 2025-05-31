// File: lib/phone_mockup/app_info_screen.dart
 
import 'package:flutter/material.dart';
import 'clickable_outline.dart'; // Import the new file

class AppInfoScreen extends StatelessWidget {
  final Map<String, String> app;
  final VoidCallback onBack;
  // This callback is specifically for navigating to the ClearDataScreen
  final void Function(Map<String, String> app) onNavigateToClearData;
  // Updated showDialog signature
  final void Function(Widget dialog, {Map<String, GlobalKey<ClickableOutlineState>>? dialogSpecificOutlineKeys}) showDialog;
  final void Function() dismissDialog;
  final Map<String, GlobalKey<ClickableOutlineState>> activeOutlineKeys; // Added field

  const AppInfoScreen({
    super.key,
    required this.app,
    required this.onBack,
    required this.onNavigateToClearData,
    required this.showDialog,
    required this.dismissDialog,
    required this.activeOutlineKeys, // Added constructor parameter
  });

  @override
  Widget build(BuildContext context) {
    print('AppInfoScreen: build method called for app: ${app['name']}');

    // Helper to create and register a key for a ClickableOutline
    GlobalKey<ClickableOutlineState> _registerKey(String keyName, dynamic widget) {
      final key = GlobalKey<ClickableOutlineState>(debugLabel: keyName);
      widget.activeOutlineKeys[keyName] = key;
      return key;
    }

    // It's generally better for the container (PhoneMockupContainerState) to clear keys
    // before this screen is built. But if AppInfoScreen needs to manage its own set,
    // it should do so carefully, perhaps by removing only keys it's certain it owns
    // if they are not already managed by PhoneMockupContainerState's clearing logic.
    // For now, we assume PhoneMockupContainerState has prepared activeOutlineKeys.

    final GlobalKey<ClickableOutlineState> backButtonKey = _registerKey("appinfo_back_button", this);
    final GlobalKey<ClickableOutlineState> openRowKey = _registerKey("appinfo_open_row", this);
    final GlobalKey<ClickableOutlineState> storageCacheRowKey = _registerKey("appinfo_storage_cache_row", this);
    final GlobalKey<ClickableOutlineState> mobileDataRowKey = _registerKey("appinfo_mobile_data_row", this);
    final GlobalKey<ClickableOutlineState> batteryRowKey = _registerKey("appinfo_battery_row", this);
    final GlobalKey<ClickableOutlineState> notificationsRowKey = _registerKey("appinfo_notifications_row", this);
    final GlobalKey<ClickableOutlineState> permissionsRowKey = _registerKey("appinfo_permissions_row", this);
    final GlobalKey<ClickableOutlineState> openByDefaultRowKey = _registerKey("appinfo_open_by_default_row", this);
    final GlobalKey<ClickableOutlineState> uninstallRowKey = _registerKey("appinfo_uninstall_row", this);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: ClickableOutline(
          key: backButtonKey, // Assign key
          onTap: () {
            print('AppInfoScreen: Back button pressed');
            onBack();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: const Text(
          'App info',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                Image.asset(
                  app['icon']!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  app['name']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version ${app['version']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),
            _buildInfoCard([
              _buildInfoRow(context, 'Open', '', key: openRowKey, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening ${app['name']}")),
                );
              }),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow(context, 'Storage & cache', app['totalSize'] ?? '0 B', key: storageCacheRowKey, onTap: () {
                print('AppInfoScreen: Storage & cache tapped. Navigating to ClearDataScreen.');
                onNavigateToClearData(app);
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Mobile data & Wi-Fi', '', key: mobileDataRowKey, onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Battery', '', key: batteryRowKey, onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Notifications', '', key: notificationsRowKey, onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Permissions', '', key: permissionsRowKey, onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Open by default', '', key: openByDefaultRowKey, onTap: () {}),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow(context, 'Uninstall', '', key: uninstallRowKey, onTap: () {
                final GlobalKey<ClickableOutlineState> uninstallDialogCancelKey = GlobalKey<ClickableOutlineState>(debugLabel: "dialog_uninstall_cancel");
                final GlobalKey<ClickableOutlineState> uninstallDialogConfirmKey = GlobalKey<ClickableOutlineState>(debugLabel: "dialog_uninstall_confirm");

                // Add keys to the activeOutlineKeys map before showing the dialog
                final dialogSpecificKeys = {
                  "dialog_uninstall_cancel": uninstallDialogCancelKey,
                  "dialog_uninstall_confirm": uninstallDialogConfirmKey,
                };
                // No need to add to widget.activeOutlineKeys directly here if PhoneMockupContainerState._showDialog handles it.
                // widget.activeOutlineKeys.addAll(dialogSpecificKeys); // This would also work but might be redundant.

              showDialog(
                AlertDialog(
                  title: const Text('Uninstall App?'),
                  content: Text('Do you want to uninstall ${app['name']}?'),
                  actions: [
                    ClickableOutline(
                      key: uninstallDialogCancelKey,
                      onTap: () {
                        dismissDialog();
                      },
                      child: TextButton(
                        onPressed: () {
                          dismissDialog();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    ClickableOutline(
                      key: uninstallDialogConfirmKey,
                      onTap: () {
                        dismissDialog();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${app['name']} uninstalled!')),
                        );
                        onBack();
                      },
                      child: TextButton(
                        onPressed: () {
                          dismissDialog();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${app['name']} uninstalled!')),
                          );
                          onBack();
                        },
                        child: const Text('Uninstall'),
                      ),
                    ),
                  ],
                ),
                dialogSpecificOutlineKeys: dialogSpecificKeys,
              );
            }),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String subtitle, {VoidCallback? onTap, required GlobalKey<ClickableOutlineState> key}) {
    return ClickableOutline( // Wrap with ClickableOutline
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title tapped")),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}