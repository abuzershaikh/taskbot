// File: lib/phone_mockup/app_grid.dart
import 'package:flutter/material.dart';
import 'dart:math'; // Import for Random
import 'clickable_outline.dart'; // Import the new file

class AppGrid extends StatefulWidget {
  final ValueChanged<String> onAppSelected;
  final ValueChanged<Map<String, String>> onAppLongPress;
  final Map<String, GlobalKey<ClickableOutlineState>> appItemKeys; // New parameter

  const AppGrid({
    super.key,
    required this.onAppSelected,
    required this.onAppLongPress,
    required this.appItemKeys, // New parameter
  });

  @override
  State<AppGrid> createState() => AppGridState();
}

class AppGridState extends State<AppGrid> {
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  List<Map<String, String>> _apps = [];

  @override
  void initState() {
    super.initState();
    _apps = _generateRandomAppSizes(_initialApps);
    // Initialize keys for existing apps in the passed map
    for (var app in _apps) {
      if (!widget.appItemKeys.containsKey(app['name'])) {
        widget.appItemKeys[app['name']!] = GlobalKey<ClickableOutlineState>();
      }
    }
  }

  // Method to get app details by name, callable from outside via appGridKey
  Map<String, String>? getAppByName(String appName) {
    return _apps.firstWhere(
      (app) => app['name'] == appName,
      orElse: () => {}, // Return empty map if not found
    );
  }

  // Method to update app data size, callable from PhoneMockupContainerState
  Future<void> updateAppDataSize(String appName, String newDataSize, String newCacheSize) async {
    final index = _apps.indexWhere((app) => app['name'] == appName);
    if (index != -1) {
      setState(() {
        final currentApp = _apps[index];
        final double currentAppSize = double.tryParse(currentApp['appSize']?.replaceAll(' MB', '') ?? '0') ?? 0;
        final double updatedDataSize = double.tryParse(newDataSize.replaceAll(' MB', '')) ?? 0;
        final double updatedCacheSize = double.tryParse(newCacheSize.replaceAll(' MB', '')) ?? 0;
        final double newTotalSize = currentAppSize + updatedDataSize + updatedCacheSize;

        _apps[index] = {
          ...currentApp,
          'dataSize': newDataSize,
          'cacheSize': newCacheSize,
          'totalSize': '${newTotalSize.toStringAsFixed(1)} MB',
        };
      });
      print('App data/cache updated for $appName. New sizes: Data=$newDataSize, Cache=$newCacheSize');
    } else {
      print('App $appName not found to update data size.');
    }
  }

  static const List<Map<String, String>> _initialApps = [
    {'name': 'Chrome', 'icon': 'assets/icons/chrome.png', 'version': '124.0.0.0'},
    {'name': 'Gmail', 'icon': 'assets/icons/gmail.png', 'version': '2024.04.28.623192461'},
    {'name': 'Maps', 'icon': 'assets/icons/maps.png', 'version': '11.125.0101'},
    {'name': 'Photos', 'icon': 'assets/icons/photos.png', 'version': '6.84.0.621017366'},
    {'name': 'YouTube', 'icon': 'assets/icons/youtube.png', 'version': '19.18.33'},
    {'name': 'Drive', 'icon': 'assets/icons/drive.png', 'version': '2.24.167.0.90'},
    {'name': 'Calendar', 'icon': 'assets/icons/calendar.png', 'version': '2024.17.0-629237913-release'},
    {'name': 'Clock', 'icon': 'assets/icons/clock.png', 'version': '8.2.0'},
    {'name': 'Camera', 'icon': 'assets/icons/camera.png', 'version': '9.2.100.612808000'},
    {'name': 'Play Store', 'icon': 'assets/icons/play_store.png', 'version': '40.6.31-21'},
    {'name': 'Files', 'icon': 'assets/icons/files.png', 'version': '1.0.623214532'},
    {'name': 'Calculator', 'icon': 'assets/icons/calculator.png', 'version': '8.2 (531942488)'},
    {'name': 'Messages', 'icon': 'assets/icons/messages.png', 'version': '20240424_02_RC00.phone_dynamic'},
    {'name': 'Phone', 'icon': 'assets/icons/phone.png', 'version': '124.0.0.612808000'},
    {'name': 'Contacts', 'icon': 'assets/icons/contacts.png', 'version': '4.29.17.625340050'},
    {'name': 'Weather', 'icon': 'assets/icons/weather.png', 'version': '1.0'},
    {'name': 'Spotify', 'icon': 'assets/icons/spotify.png', 'version': '8.9.36.568'},
    {'name': 'WhatsApp', 'icon': 'assets/icons/whatsapp.png', 'version': '2.24.10.74'},
    {'name': 'Instagram', 'icon': 'assets/icons/instagram.png', 'version': '312.0.0.32.112'},
    {'name': 'Netflix', 'icon': 'assets/icons/netflix.png', 'version': '8.100.1'},
    {'name': 'Facebook', 'icon': 'assets/icons/facebook.png', 'version': '473.0.0.35.109'},
    {'name': 'Twitter', 'icon': 'assets/icons/twitter.png', 'version': '10.37.0-release.0'},
    {'name': 'Snapchat', 'icon': 'assets/icons/snapchat.png', 'version': '12.87.0.40'},
    {'name': 'TikTok', 'icon': 'assets/icons/tiktok.png', 'version': '34.8.4'},
    {'name': 'Pinterest', 'icon': 'assets/icons/pinterest.png', 'version': '11.20.0'},
    {'name': 'Amazon', 'icon': 'assets/icons/amazon.png', 'version': '25.21.1.800'},
    {'name': 'Settings', 'icon': 'assets/icons/settings.png', 'version': '1.0.0'},
  ];

  List<Map<String, String>> _generateRandomAppSizes(List<Map<String, String>> apps) {
    return apps.map((app) {
      final double appSizeMB = _random.nextDouble() * (200 - 50) + 50;
      final double dataSizeMB = _random.nextDouble() * (100 - 10) + 10;
      final double cacheSizeMB = _random.nextDouble() * (50 - 5) + 5;
      final double totalSizeMB = appSizeMB + dataSizeMB + cacheSizeMB;

      return {
        ...app,
        'appSize': '${appSizeMB.toStringAsFixed(1)} MB',
        'dataSize': '${dataSizeMB.toStringAsFixed(1)} MB',
        'cacheSize': '${cacheSizeMB.toStringAsFixed(1)} MB',
        'totalSize': '${totalSizeMB.toStringAsFixed(1)} MB',
      };
    }).toList();
  }

  void scrollToApp(String appName) {
    final index = _apps.indexWhere((app) => app['name'] == appName);
    if (index != -1) {
      const double itemHeight = 50 + 8 + 12 + 16;
      final double offset = (index ~/ 3) * itemHeight;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          // Ensure a key exists for this app in the passed map
          if (!widget.appItemKeys.containsKey(app['name'])) {
             widget.appItemKeys[app['name']!] = GlobalKey<ClickableOutlineState>(debugLabel: 'App: ${app['name']}');
          }
          final appKey = widget.appItemKeys[app['name']!]!;

          return ClickableOutline(
            key: appKey, // Assign the GlobalKey here
            onTap: () {
              widget.onAppSelected(app['name']!);
            },
            onLongPress: () {
              widget.onAppLongPress(app);
            },
            child: Column(
              children: [
                Image.asset(
                  app['icon']!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  app['name']!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}