import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;
  const SettingsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    // Define the settings sections and their items
    final List<Map<String, dynamic>> primarySettings = [
      {'icon': Icons.wifi, 'title': 'Wi-Fi', 'trailing': 'Off', 'isToggle': false},
      {'icon': Icons.swap_vert, 'title': 'Mobile network', 'trailing': null},
      {'icon': Icons.bluetooth, 'title': 'Bluetooth', 'trailing': 'Off'},
      {'icon': Icons.share, 'title': 'Connection & sharing', 'trailing': null},
    ];

    final List<Map<String, dynamic>> displaySettings = [
      {'icon': Icons.palette_outlined, 'title': 'Wallpapers & style', 'trailing': null},
      {'icon': Icons.apps, 'title': 'Home screen & Lock screen', 'trailing': null},
      {'icon': Icons.wb_sunny_outlined, 'title': 'Display & brightness', 'trailing': null},
      {'icon': Icons.volume_up_outlined, 'title': 'Sound & vibration', 'trailing': null},
      {'icon': Icons.notifications_none, 'title': 'Notification & status bar', 'trailing': null},
    ];

    final List<Map<String, dynamic>> appSecuritySettings = [
      {'icon': Icons.apps, 'title': 'Apps', 'trailing': null},
      {'icon': Icons.security_outlined, 'title': 'Password & security', 'trailing': null},
    ];


    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard(context, primarySettings),
          const SizedBox(height: 16),

          _buildSettingsCard(context, displaySettings),
          const SizedBox(height: 16),

          _buildSettingsCard(context, appSecuritySettings),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Map<String, dynamic>> items) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: items.map((item) {
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'] as IconData, color: Colors.blue[700]),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500, // Changed to medium bold (w500)
                      // You can try FontWeight.bold (w700) for even thicker text
                    ),
                  ),
                  trailing: item['trailing'] != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['trailing'] as String,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    print('${item['title']} tapped!');
                  },
                ),
                if (item != items.last)
                  const Divider(
                    indent: 72,
                    endIndent: 16,
                    height: 1,
                    color: Colors.black12,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}