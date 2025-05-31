// File: lib/phone_mockup/app_info_screen.dart
 
import 'package:flutter/material.dart';
// Removed: import 'clickable_outline.dart';

class AppInfoScreen extends StatelessWidget {
  final Map<String, String> app;
  final VoidCallback onBack;
  // This callback is specifically for navigating to the ClearDataScreen
  final void Function(Map<String, String> app) onNavigateToClearData;
  final void Function(Widget dialog) showDialog;
  final void Function() dismissDialog;

  const AppInfoScreen({
    super.key,
    required this.app,
    required this.onBack,
    required this.onNavigateToClearData,
    required this.showDialog,
    required this.dismissDialog,
  });

  @override
  Widget build(BuildContext context) {
    // print('AppInfoScreen: build method called for app: ${app['name']}');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: GestureDetector( // Replaced ClickableOutline
          onTap: () {
            // print('AppInfoScreen: Back button pressed');
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
              _buildInfoRow(context, 'Open', '', onTap: () {
                // You might want to define what 'Open' does
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening ${app['name']}")),
                );
              }),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow(context, 'Storage & cache', app['totalSize'] ?? '0 B', onTap: () {
                // print('AppInfoScreen: Storage & cache tapped. Navigating to ClearDataScreen.');
                onNavigateToClearData(app);
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Mobile data & Wi-Fi', '', onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Battery', '', onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Notifications', '', onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Permissions', '', onTap: () {}),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, 'Open by default', '', onTap: () {}),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow(context, 'Uninstall', '', onTap: () {
                // Placeholder for uninstall dialog
                showDialog(
                  AlertDialog(
                    title: const Text('Uninstall App?'),
                    content: Text('Do you want to uninstall ${app['name']}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          dismissDialog();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          dismissDialog();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${app['name']} uninstalled!')),
                          );
                          onBack(); // Go back after uninstall
                        },
                        child: const Text('Uninstall'),
                      ),
                    ],
                  ),
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

  Widget _buildInfoRow(BuildContext context, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector( // Replaced ClickableOutline
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title tapped")),
        );
      },
      child: Padding(
        // Added a transparent background to make the whole area tappable, similar to InkWell
        // If specific hitTestBehavior is needed, it can be added to GestureDetector.
        // For simple cases, this often works.
        // behavior: HitTestBehavior.opaque, // Example if needed
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