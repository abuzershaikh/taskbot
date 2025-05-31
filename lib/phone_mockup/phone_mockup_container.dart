// File: lib/phone_mockup/phone_mockup_container.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // For BackdropFilter

import 'app_grid.dart';
import 'settings_screen.dart';
import 'notification_drawer.dart';
import 'custom_app_action_dialog.dart';
import 'app_info_screen.dart';
import 'clear_data_screen.dart';
import 'custom_clear_data_dialog.dart'; // Ensured this import is clean

// Enum to manage the current view being displayed in the phone mockup
enum CurrentScreenView { appGrid, settings, appInfo, clearData }

class PhoneMockupContainer extends StatefulWidget {
  final GlobalKey<AppGridState> appGridKey; // Key for the AppGrid it will contain

  const PhoneMockupContainer({
    super.key, // This is the key for PhoneMockupContainer itself
    required this.appGridKey,
  });

  // Static key and method - assuming these are intended to remain, cleaned from markers.
  static final GlobalKey<PhoneMockupContainerState> globalKey =
      GlobalKey<PhoneMockupContainerState>();

  static void executeCommand(String command) {
    globalKey.currentState?._handleCommand(command);
  }

  @override
  State<PhoneMockupContainer> createState() => PhoneMockupContainerState();
}

class PhoneMockupContainerState extends State<PhoneMockupContainer> {
  final GlobalKey<NotificationDrawerState> _drawerKey =
      GlobalKey<NotificationDrawerState>();

  CurrentScreenView _currentScreenView = CurrentScreenView.appGrid;
  Map<String, String>? _currentAppDetails; // To store details of the app being interacted with
  Widget _currentAppScreenWidget = const SizedBox(); // Holds the actual widget to display

  bool _isBlurred = false;
  Widget? _activeDialog;

  // Make dismissDialog public
  void dismissDialog() { // Renamed from _dismissDialog to dismissDialog
    setState(() {
      _activeDialog = null;
      _isBlurred = false;
    });
  }

  // get activeDialogInstance => null; // This getter is redundant if _activeDialog is handled internally. Removed for clarity.


  @override
  void initState() {
    super.initState();
    _updateCurrentScreenWidget(); // Initialize with AppGrid
  }

  void _updateCurrentScreenWidget() {
    switch (_currentScreenView) {
      case CurrentScreenView.appGrid:
        _currentAppScreenWidget = AppGrid(
          key: widget.appGridKey, // Use the key passed to PhoneMockupContainer
          onAppSelected: _handleAppTap,
          onAppLongPress: handleAppLongPress, appItemKeys: {}, // Ensured this line is clean
        );
        break;
      case CurrentScreenView.settings:
        _currentAppScreenWidget = SettingsScreen(
          onBack: () {
            setState(() {
              _currentScreenView = CurrentScreenView.appGrid;
              _currentAppDetails = null;
              _updateCurrentScreenWidget();
            });
          },
        );
        break;
      case CurrentScreenView.appInfo:
        if (_currentAppDetails != null) {
          _currentAppScreenWidget = AppInfoScreen(
            app: _currentAppDetails!,
            onBack: () {
              setState(() {
                _currentScreenView = CurrentScreenView.appGrid;
                _currentAppDetails = null;
                _updateCurrentScreenWidget();
              });
            },
            onNavigateToClearData: (appData) { // This is the "Storage & Cache" tap
              navigateToStorageUsage(); // Use the new method
            },
            showDialog: _showDialog,
            dismissDialog: dismissDialog, // Use the public method
          );
        } else {
          // Fallback to AppGrid if details are missing
          _currentScreenView = CurrentScreenView.appGrid;
          _updateCurrentScreenWidget();
        }
        break;
      case CurrentScreenView.clearData:
        if (_currentAppDetails != null) {
          _currentAppScreenWidget = ClearDataScreen(
            appName: _currentAppDetails!['name']!,
            appVersion: _currentAppDetails!['version'] ?? 'N/A',
            appIconPath: _currentAppDetails!['icon']!,
            initialTotalSize: _currentAppDetails!['totalSize'] ?? '0 B',
            initialAppSize: _currentAppDetails!['appSize'] ?? '0 B',
            initialDataSize: _currentAppDetails!['dataSize'] ?? '0 B',
            initialCacheSize: _currentAppDetails!['cacheSize'] ?? '0 B',
            onBack: () {
              setState(() {
                _currentScreenView = CurrentScreenView.appInfo;
                _updateCurrentScreenWidget();
              });
            },
            showDialog: _showDialog,
            dismissDialog: dismissDialog, // Use the public method
            // Pass the actual clearing functions
            onPerformClearData: () => _performActualDataClear(_currentAppDetails!['name']!),
            onPerformClearCache: () => _performActualCacheClear(_currentAppDetails!['name']!),
          );
        } else {
          _currentScreenView = CurrentScreenView.appGrid;
          _updateCurrentScreenWidget();
        }
        break;
    }
  }


  // Callback to set the blur state from child widgets - now internal to the dialog logic
  // void _setBlurState(bool isBlurred) { // This method is now implicitly handled by _showDialog and dismissDialog
  //   setState(() {
  //     _isBlurred = isBlurred;
  //   });
  // }

  void _handleCommand(String command) {
    final cmd = command.toLowerCase().trim();
    if (cmd.contains('settings')) {
      _handleAppTap('Settings'); // This will set _currentScreenView to settings
    } else if (cmd.contains('back')) {
      // Trigger the onBack of the current screen widget if it has one
      if (_currentScreenView == CurrentScreenView.appInfo && _currentAppDetails != null) {
        setState(() {
          _currentScreenView = CurrentScreenView.appGrid;
          _currentAppDetails = null;
          _updateCurrentScreenWidget();
        });
      } else if (_currentScreenView == CurrentScreenView.settings) {
         setState(() {
          _currentScreenView = CurrentScreenView.appGrid;
          _updateCurrentScreenWidget();
        });
      } else if (_currentScreenView == CurrentScreenView.clearData && _currentAppDetails != null) {
        setState(() {
          _currentScreenView = CurrentScreenView.appInfo;
          _updateCurrentScreenWidget();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Already on main screen or no back action defined')),
          );
        }
      }
    } else if (cmd.contains('notification')) {
      _openNotificationDrawer();
    } else if (cmd.startsWith('scroll to')) {
      final appName = cmd.substring('scroll to'.length).trim();
      if (widget.appGridKey.currentState != null) {
        widget.appGridKey.currentState?.scrollToApp(appName);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AppGrid not ready to scroll.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown command: $command')),
        );
      }
    }
  }

  void _handleAppTap(String appName) {
    // ignore: avoid_print
    print('PhoneMockupContainer: App tapped: $appName');
    if (appName == 'Settings') {
      setState(() {
        _currentScreenView = CurrentScreenView.settings;
        _currentAppDetails = null;
        _updateCurrentScreenWidget();
      });
    } else {
      final appDetails = widget.appGridKey.currentState?.getAppByName(appName);
      if (appDetails != null) {
        setState(() {
          _currentAppDetails = Map<String, String>.from(appDetails);
          _currentScreenView = CurrentScreenView.appInfo;
          _updateCurrentScreenWidget();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("App '$appName' details not found.")),
          );
        }
      }
    }
  }

  void handleAppLongPress(Map<String, String> app) {
    // ignore: avoid_print
    print('PhoneMockupContainer: Long press on app: ${app['name']}');
    _currentAppDetails = Map<String, String>.from(app);

    setState(() {
      _isBlurred = true; // Set blur when dialog is active
      _activeDialog = CustomAppActionDialog(
        app: _currentAppDetails!,
        onActionSelected: (actionName, appDetailsFromDialog) {
          dismissDialog(); // Dismiss the dialog using the now public method
          if (actionName == 'App info') {
            navigateToAppInfo(appDetails: appDetailsFromDialog);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$actionName for ${appDetailsFromDialog['name'] ?? 'unknown app'}")),
              );
            }
          }
        },
      );
    });
  }

  void navigateToAppInfo({Map<String, String>? appDetails}) {
    final detailsToUse = appDetails ?? _currentAppDetails;

    if (detailsToUse != null) {
      if (appDetails != null && _currentAppDetails != appDetails) {
          _currentAppDetails = appDetails;
      }
      setState(() {
        _currentScreenView = CurrentScreenView.appInfo;
        _updateCurrentScreenWidget();
        // ignore: avoid_print
        print("PhoneMockupContainer: Navigated to AppInfo for ${detailsToUse['name']}");
      });
    } else {
      // ignore: avoid_print
      print("PhoneMockupContainer: Error - AppDetails is null for navigateToAppInfo.");
    }
  }

  void navigateToStorageUsage() {
    if (_currentScreenView == CurrentScreenView.appInfo && _currentAppDetails != null) {
      setState(() {
        _currentScreenView = CurrentScreenView.clearData;
        _updateCurrentScreenWidget();
        // ignore: avoid_print
        print("PhoneMockupContainer: Navigated to ClearDataScreen for ${_currentAppDetails!['name']}");
      });
    } else {
      // ignore: avoid_print
      print("PhoneMockupContainer: Error - Not on AppInfo or _currentAppDetails is null for navigateToStorageUsage.");
    }
  }

  Future<void> _performActualDataClear(String appName) async {
    // ignore: avoid_print
    print("PhoneMockupContainer: Performing actual data clear for $appName");
    await widget.appGridKey.currentState?.updateAppDataSize(appName, '0 B', _currentAppDetails?['cacheSize'] ?? '0 B');

    if (_currentAppDetails != null && _currentAppDetails!['name'] == appName) {
      setState(() {
        _currentAppDetails!['dataSize'] = '0 B';
        double appSizeMB = double.tryParse(_currentAppDetails!['appSize']!.replaceAll(' MB', '')) ?? 0;
        double cacheSizeMB = double.tryParse(_currentAppDetails!['cacheSize']!.replaceAll(' MB', '')) ?? 0;
        _currentAppDetails!['totalSize'] = '${(appSizeMB + cacheSizeMB).toStringAsFixed(1)} MB';
      });
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data cleared for $appName')));
    }
    if (_currentScreenView == CurrentScreenView.clearData) _updateCurrentScreenWidget();
  }

  Future<void> _performActualCacheClear(String appName) async {
    // ignore: avoid_print
    print("PhoneMockupContainer: Performing actual cache clear for $appName");
    await widget.appGridKey.currentState?.updateAppDataSize(appName, _currentAppDetails?['dataSize'] ?? '0 B', '0 B');

    if (_currentAppDetails != null && _currentAppDetails!['name'] == appName) {
      setState(() {
        _currentAppDetails!['cacheSize'] = '0 B';
        double appSizeMB = double.tryParse(_currentAppDetails!['appSize']!.replaceAll(' MB', '')) ?? 0;
        double dataSizeMB = double.tryParse(_currentAppDetails!['dataSize']!.replaceAll(' MB', '')) ?? 0;
        _currentAppDetails!['totalSize'] = '${(appSizeMB + dataSizeMB).toStringAsFixed(1)} MB';
      });
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cache cleared for $appName')));
    }
    if (_currentScreenView == CurrentScreenView.clearData) _updateCurrentScreenWidget();
  }

  void simulateClearDataClick() {
    if (_currentScreenView == CurrentScreenView.clearData && _currentAppDetails != null) {
      final String appName = _currentAppDetails!['name']!;
      // ignore: avoid_print
      print("PhoneMockupContainer: simulateClearDataClick for $appName");
      _showDialog(
        CustomClearDataDialog(
          title: 'Clear app data?',
          content: 'This apps data, including files and settings, will be permanently deleted from this device.',
          confirmButtonText: 'Delete',
          confirmButtonColor: Colors.red,
          onConfirm: () {
            dismissDialog(); // Use the public method
            _performActualDataClear(appName);
          },
          onCancel: dismissDialog, // Use the public method
        ),
      );
    } else {
      // ignore: avoid_print
      print("PhoneMockupContainer: Error - Not on ClearData screen or no app selected for simulateClearDataClick.");
    }
  }

  void simulateConfirmDelete() {
    if (_activeDialog != null && _currentAppDetails != null) {
      // We need to check if the active dialog is indeed the CustomClearDataDialog
      // and then manually call its onConfirm. Since we don't have direct access
      // to the internal state of the dialog once it's rendered as a Widget?,
      // the safest way to simulate the confirm is to re-trigger the data clear directly
      // if we are sure it's the right context.
      // A more robust solution might involve passing a callback or using a more
      // explicit state management for dialogs. For now, assume this is called
      // when a clear data dialog is expected.
      final String appName = _currentAppDetails!['name']!;
      // ignore: avoid_print
      print("PhoneMockupContainer: simulateConfirmDelete for $appName from active dialog.");
      dismissDialog(); // Use the public method
      _performActualDataClear(appName);
    } else {
      // ignore: avoid_print
      print("PhoneMockupContainer: Error - No active dialog or no app details for simulateConfirmDelete. _activeDialog is ${_activeDialog == null ? 'null' : 'not null'}, _currentAppDetails is ${_currentAppDetails == null ? 'null' : 'not null'}");
    }
  }

  void navigateHome() {
    setState(() {
      _currentScreenView = CurrentScreenView.appGrid;
      _currentAppDetails = null;
      dismissDialog(); // Ensure any open dialog is dismissed when navigating home
      _updateCurrentScreenWidget();
      // ignore: avoid_print
      print("PhoneMockupContainer: Navigated to Home (AppGrid).");
    });
  }

  void _openNotificationDrawer() {
    _drawerKey.currentState?.openDrawer();
  }

  void _showDialog(Widget dialog) {
    setState(() {
      _activeDialog = dialog;
      _isBlurred = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _openNotificationDrawer,
                child: _buildStatusBar(),
              ),
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: const Divider(
                height: 1,
                color: Colors.white30,
              ),
            ),
            Positioned.fill(
              top: 31,
              child: Material(
                type: MaterialType.transparency,
                child: _currentAppScreenWidget,
              ),
            ),
            if (_isBlurred)
              // Only apply blur if a dialog is active
              Positioned.fill(
                top: 31, // Start blur below status bar
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.0), // Transparent overlay
                  ),
                ),
              ),
            if (_activeDialog != null)
              Positioned.fill(
                top: 31, // Position dialog below status bar
                child: GestureDetector( // Add GestureDetector to dismiss dialog on tap outside
                  onTap: dismissDialog, // Use the public method to dismiss
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // Dark overlay for dialog
                    child: Center(
                      child: GestureDetector( // Prevent dialog itself from dismissing on tap
                        onTap: () {}, // Empty onTap to consume the tap event
                        child: _activeDialog!,
                      ),
                    ),
                  ),
                ),
              ),
            NotificationDrawer(key: _drawerKey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    String formattedTime = DateFormat('h:mm a').format(DateTime.now());

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedTime,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Row(
            children: const [
              Icon(
                Icons.signal_cellular_alt,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 4),
              Icon(Icons.wifi, color: Colors.white, size: 18),
              SizedBox(width: 4),
              Text(
                "81%",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.battery_full,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}