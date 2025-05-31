import 'package:flutter/material.dart';
import 'clickable_outline.dart'; // Import the new file

class ClearDataScreen extends StatelessWidget {
  final String appName;
  final String appVersion;
  final String appIconPath;
  final String initialTotalSize;
  final String initialAppSize;
  final String initialDataSize;
  final String initialCacheSize;
  final VoidCallback onBack;
  final VoidCallback onPerformClearData;
  final VoidCallback onPerformClearCache;
  final void Function(Widget dialog, {Map<String, GlobalKey<ClickableOutlineState>>? dialogSpecificOutlineKeys}) showDialog; // Updated signature
  final void Function() dismissDialog; // From PhoneMockupContainer
  final Map<String, GlobalKey<ClickableOutlineState>> activeOutlineKeys; // Added field

  const ClearDataScreen({
    super.key,
    required this.appName,
    required this.activeOutlineKeys, // Added parameter
    required this.appVersion,
    required this.appIconPath,
    required this.initialTotalSize,
    required this.initialAppSize,
    required this.initialDataSize,
    required this.initialCacheSize,
    required this.onBack,
    required this.onPerformClearData,
    required this.onPerformClearCache,
    required this.showDialog,
    required this.dismissDialog,
  });

  @override
  Widget build(BuildContext context) {
    print('ClearDataScreen: build method called for app: $appName'); // DEBUG

    GlobalKey<ClickableOutlineState> _registerKey(String keyName, dynamic widget) {
      final key = GlobalKey<ClickableOutlineState>(debugLabel: keyName);
      widget.activeOutlineKeys[keyName] = key;
      return key;
    }

    final backButtonKey = _registerKey("cleardata_back_button", this);
    final clearDataRowKey = _registerKey("cleardata_clear_data_row", this);
    final clearCacheRowKey = _registerKey("cleardata_clear_cache_row", this);
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: ClickableOutline(
          key: backButtonKey, // Assign key
          onTap: onBack,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: Text(
          appName,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App icon and name
            Column(
              children: [
                Image.asset(
                  appIconPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  appName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version $appVersion',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),

            // Storage details card
            _buildInfoCard([
              _buildInfoRow('Total', initialTotalSize),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow('App size', initialAppSize),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow('User data', initialDataSize),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow('Cache', initialCacheSize),
            ]),
            const SizedBox(height: 20),

            // Clear data/cache buttons
            _buildInfoCard([
              ClickableOutline(
                key: clearDataRowKey, // Assign key
                onTap: () {
                  print('ClearDataScreen: Clear data button tapped. Calling showDialog...'); // DEBUG
                  final cancelKey = GlobalKey<ClickableOutlineState>(debugLabel: "dialog_cleardata_confirm_cancel");
                  final confirmKey = GlobalKey<ClickableOutlineState>(debugLabel: "dialog_cleardata_confirm_delete");
                  final dialogKeys = {
                    "dialog_cleardata_confirm_cancel": cancelKey,
                    "dialog_cleardata_confirm_delete": confirmKey,
                  };

                  showDialog(
                    AlertDialog(
                      title: const Text('Clear app data?'),
                      content: const Text('This app\'s data, including files and settings, will be permanently deleted from this device.'),
                      actions: [
                        ClickableOutline(
                          key: cancelKey,
                          onTap: dismissDialog,
                          child: TextButton(
                            onPressed: dismissDialog,
                            child: const Text('Cancel'),
                          ),
                        ),
                        ClickableOutline(
                          key: confirmKey,
                          onTap: () {
                            dismissDialog();
                            onPerformClearData();
                          },
                          child: TextButton(
                            onPressed: () {
                              dismissDialog();
                              onPerformClearData();
                            },
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                    dialogSpecificOutlineKeys: dialogKeys,
                  );
                },
                child: _buildButtonRow(Icons.delete_outline, 'Clear data', 'Delete all app data'),
              ),
              const Divider(height: 0, indent: 16, endIndent: 16),
              ClickableOutline(
                key: clearCacheRowKey, // Assign key
                onTap: () {
                  print('ClearDataScreen: Clear cache button tapped. Calling showDialog...'); // DEBUG
                  final cancelKey = GlobalKey<ClickableOutlineState>(debugLabel: "dialog_clearcache_confirm_cancel");
                  final confirmKey = GlobalKey<ClickableOutlineState>(debugLabel: "dialog_clearcache_confirm_clear");
                  final dialogKeys = {
                    "dialog_clearcache_confirm_cancel": cancelKey,
                    "dialog_clearcache_confirm_clear": confirmKey,
                  };
                  showDialog(
                    AlertDialog(
                      title: const Text('Clear cache?'),
                      content: const Text('This will clear the cached data for the app.'),
                      actions: [
                        ClickableOutline(
                          key: cancelKey,
                          onTap: dismissDialog,
                          child: TextButton(
                            onPressed: dismissDialog,
                            child: const Text('Cancel'),
                          ),
                        ),
                        ClickableOutline(
                          key: confirmKey,
                          onTap: () {
                            dismissDialog();
                            onPerformClearCache();
                          },
                          child: TextButton(
                            onPressed: () {
                              dismissDialog();
                              onPerformClearCache();
                            },
                            child: const Text('Clear Cache'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: _buildButtonRow(Icons.cached, 'Clear cache', 'Delete temporary files'),
              ),
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

  Widget _buildInfoRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}