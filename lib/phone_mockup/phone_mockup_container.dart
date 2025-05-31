import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // For BackdropFilter

import 'app_grid.dart';
import 'settings_screen.dart';
import 'notification_drawer.dart';
import 'custom_app_action_dialog.dart';
import 'app_info_screen.dart';
import 'clear_data_screen.dart';
import 'custom_clear_data_dialog.dart';
import 'clickable_outline.dart'; // Added import

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

  final Map<String, GlobalKey<ClickableOutlineState>> activeOutlineKeys = {}; // Renamed

  bool _isBlurred = false;
  Widget? _activeDialog;

  // Make dismissDialog public
  void dismissDialog() {
    setState(() {
      _activeDialog = null;
      _isBlurred = false;
      // Remove dialog-specific keys
      activeOutlineKeys.removeWhere((key, value) => key.startsWith("dialog_"));
      // ignore: avoid_print
      print("Cleared dialog keys. Current keys: ${activeOutlineKeys.keys.toList()}");
    });
  }


  @override
  void initState() {
    super.initState();
    _updateCurrentScreenWidget(); // Initialize with AppGrid
  }

  void _updateCurrentScreenWidget() {
    // ignore: avoid_print
    print("[DEBUG] _updateCurrentScreenWidget: Entered. CurrentScreenView: $_currentScreenView, CurrentAppDetails: $_currentAppDetails");
    // Clear non-AppGrid keys before building a new screen that is not AppGrid
    if (_currentScreenView != CurrentScreenView.appGrid) {
      activeOutlineKeys.removeWhere((key, value) => !key.startsWith("appgrid_"));
      // ignore: avoid_print
      print("Cleared non-appgrid keys. Current keys: ${activeOutlineKeys.keys.toList()}");
    }

    switch (_currentScreenView) {
      case CurrentScreenView.appGrid:
        // ignore: avoid_print
        print("[DEBUG] _updateCurrentScreenWidget: Case AppGrid. Attempting to build AppGrid.");
        // AppGrid will populate the activeOutlineKeys map.
        _currentAppScreenWidget = AppGrid(
          key: widget.appGridKey,
          onAppSelected: _handleAppTap,
          onAppLongPress: handleAppLongPress,
          appItemKeys: activeOutlineKeys, // Pass the map here
        );
        break;
      case CurrentScreenView.settings:
        // ignore: avoid_print
        print("[DEBUG] _updateCurrentScreenWidget: Case Settings. Attempting to build SettingsScreen.");
        // SettingsScreen doesn't currently use activeOutlineKeys.
        // If it did, we might need a more nuanced clearing strategy or pass activeOutlineKeys.
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
        // ignore: avoid_print
        print("[DEBUG] _updateCurrentScreenWidget: Case AppInfo. Attempting to build AppInfoScreen for app: ${_currentAppDetails?['name']}");
        if (_currentAppDetails != null) {
          _currentAppScreenWidget = AppInfoScreen(
            app: _currentAppDetails!,
            activeOutlineKeys: activeOutlineKeys, // Pass the map
            onBack: () {
              setState(() {
                _currentScreenView = CurrentScreenView.appGrid;
                _currentAppDetails = null;
                _updateCurrentScreenWidget();
              });
            },
            onNavigateToClearData: (appData) {
              navigateToStorageUsage();
            },
            showDialog: _showDialog, // Pass the modified _showDialog
            dismissDialog: dismissDialog,
          );
        } else {
          _currentScreenView = CurrentScreenView.appGrid;
          _updateCurrentScreenWidget();
        }
        break;
      case CurrentScreenView.clearData:
        // ignore: avoid_print
        print("[DEBUG] _updateCurrentScreenWidget: Case ClearData. Attempting to build ClearDataScreen for app: ${_currentAppDetails?['name']}");
        if (_currentAppDetails != null) {
          _currentAppScreenWidget = ClearDataScreen(
            appName: _currentAppDetails!['name']!,
            activeOutlineKeys: activeOutlineKeys, // Pass the map
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
            showDialog: _showDialog, // Pass the modified _showDialog
            dismissDialog: dismissDialog,
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

  Future<void> _handleCommandWithOutline(String command, String targetWidgetName, VoidCallback action) async {
    // ignore: avoid_print
    print("[DEBUG] _handleCommandWithOutline: Entered. Command: '$command', TargetWidgetName: '$targetWidgetName'");
    
    // Use targetWidgetName directly as the key.
    // It's assumed that _handleCommand has already formatted it correctly (e.g., with "appgrid_" prefix if needed).
    final key = activeOutlineKeys[targetWidgetName];
    // ignore: avoid_print
    print("[DEBUG] _handleCommandWithOutline: Outline key for '$targetWidgetName' is ${key == null ? 'NOT FOUND' : 'FOUND'}. Key context: ${key?.currentContext}, Key state: ${key?.currentState}");

    if (key != null && key.currentState != null) {
      if (key.currentContext != null && key.currentContext!.mounted) {
        // ignore: avoid_print
        print("[DEBUG] _handleCommandWithOutline: Key FOUND and valid. Calling triggerOutlineAndAction for '$targetWidgetName'.");
        await key.currentState!.triggerOutlineAndAction(() {
          // ignore: avoid_print
          print("[DEBUG] _handleCommandWithOutline: Action for triggerOutlineAndAction (for $targetWidgetName) CALLED.");
          action();
        });
      } else {
        // ignore: avoid_print
        print("[DEBUG] _handleCommandWithOutline: Key for '$targetWidgetName' found but context invalid or not mounted. Executing action directly.");
        action();
      }
    } else {
      // ignore: avoid_print
      print("[DEBUG] _handleCommandWithOutline: Key for '$targetWidgetName' NOT FOUND or currentState is null. Executing action directly.");
      action();
    }
  }

  void _handleCommand(String command) {
    final cmd = command.toLowerCase().trim();
    if (cmd.startsWith('open ') || cmd.startsWith('tap ')) {
      final appNamePart = cmd.split(' ').sublist(1).join(' ');
      final capitalizedAppName = appNamePart.isNotEmpty ? appNamePart[0].toUpperCase() + appNamePart.substring(1) : appNamePart;
      // For app opening, the target name for _handleCommandWithOutline should be the prefixed AppGrid key.
      final targetWidgetName = "appgrid_$capitalizedAppName";
      _handleCommandWithOutline(command, targetWidgetName, () => _handleAppTap(capitalizedAppName));
    } else if (cmd.startsWith("tap_key ")) {
      final targetKeyName = cmd.substring("tap_key ".length).trim();
      VoidCallback action = () {
        final outlineState = activeOutlineKeys[targetKeyName]?.currentState;
        if (outlineState != null && outlineState.mounted) {
          // Check if the widget associated with the key has an onTap callback
          if (outlineState.widget.onTap != null) {
            outlineState.widget.onTap!();
          } else {
            // ignore: avoid_print
            print("Warning: onTap is null for key $targetKeyName.");
          }
        } else {
          // ignore: avoid_print
          print("Warning: ClickableOutlineState not found or not mounted for key $targetKeyName.");
        }
      };
      _handleCommandWithOutline(command, targetKeyName, action);
    } else if (cmd.contains('back')) {
      // Prioritize dialog back actions if a dialog is active
      if (_activeDialog != null) {
        // Try to find a "cancel" or "back" button in the active dialog's keys
        final dialogCancelKeyName = activeOutlineKeys.keys.firstWhere(
            (k) => k.startsWith("dialog_") && (k.toLowerCase().contains("cancel") || k.toLowerCase().contains("back")),
            orElse: () => "");
        
        if (dialogCancelKeyName.isNotEmpty) {
          final key = activeOutlineKeys[dialogCancelKeyName];
          if (key != null && key.currentState != null && key.currentContext != null && key.currentContext!.mounted) {
            // ignore: avoid_print
            print("Executing 'back' command on dialog element: $dialogCancelKeyName");
            // The action for the dialog button (e.g., calling dismissDialog) should be triggered.
            // The ClickableOutline's onTap for these dialog buttons is usually set to perform its action (e.g., dismissDialog).
            // We directly invoke that onTap via triggerOutlineAndAction.
            key.currentState!.triggerOutlineAndAction(() {
              // The onTap defined in ClickableOutline (which should call the button's original action) will be executed.
              // For example, if ClickableOutline's onTap is `() => dismissDialog()`, then `dismissDialog()` is called.
            });
            return; // Back action handled by dialog
          }
        }
      }
      // If no dialog handled back, proceed with screen-level back logic for the current screen
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
      // Fallback for "settings" command if not caught by "open/tap"
      if (cmd.contains('settings')) {
        final targetKey = "appgrid_Settings";
        _handleCommandWithOutline(command, targetKey, () => _handleAppTap('Settings'));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown command: $command')),
        );
      }
    }
  }

  void _handleAppTap(String appName) {
    // ignore: avoid_print
    print("[DEBUG] _handleAppTap: Entered. AppName: '$appName'");
    // ignore: avoid_print
    print('PhoneMockupContainer: App tapped: $appName'); // Existing log
    if (appName == 'Settings') {
      // ignore: avoid_print
      print("[DEBUG] _handleAppTap: Setting _currentScreenView = CurrentScreenView.settings.");
      setState(() {
        _currentScreenView = CurrentScreenView.settings;
        _currentAppDetails = null;
        _updateCurrentScreenWidget();
      });
    } else {
      final appDetails = widget.appGridKey.currentState?.getAppByName(appName);
      // ignore: avoid_print
      print("[DEBUG] _handleAppTap: Retrieved appDetails for '$appName': ${appDetails == null ? 'NOT FOUND' : appDetails.toString()}");
      if (appDetails != null) {
        // ignore: avoid_print
        print("[DEBUG] _handleAppTap: appDetails FOUND for '$appName'. Preparing to navigate to AppInfoScreen.");
        setState(() {
          _currentAppDetails = Map<String, String>.from(appDetails);
          // ignore: avoid_print
          print("[DEBUG] _handleAppTap: Setting _currentScreenView = CurrentScreenView.appInfo for '$appName'.");
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

  void _showAppActionDialog(Map<String, String> app) {
    // ignore: avoid_print
    print('PhoneMockupContainer: Showing app action dialog for ${app['name']}');
    _currentAppDetails = Map<String, String>.from(app);

    setState(() {
      _isBlurred = true; // Set blur when dialog is active
      _activeDialog = CustomAppActionDialog(
        app: _currentAppDetails!,
        activeOutlineKeys: activeOutlineKeys, // Pass the map here
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

  Future<void> handleAppLongPress(Map<String, String> app) async {
    final appName = app['name'];
    if (appName == null) {
      // ignore: avoid_print
      print('Warning: App name is null in handleAppLongPress. Cannot show dialog.');
      return;
    }

    // ignore: avoid_print
    print('PhoneMockupContainer: Long press on app: $appName');
    final prefixedAppName = "appgrid_$appName"; // AppGrid items are prefixed

    final key = activeOutlineKeys[prefixedAppName]; // Use prefixed name
    if (key != null && key.currentState != null && key.currentContext != null && key.currentContext!.mounted) {
      await key.currentState!.triggerOutlineAndAction(() {
        _showAppActionDialog(app);
      });
    } else {
      // ignore: avoid_print
      print('Warning: ClickableOutline key not found or not mounted for $prefixedAppName. Showing dialog directly.');
      _showAppActionDialog(app);
    }
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

  void _showDialog(Widget dialog, {Map<String, GlobalKey<ClickableOutlineState>>? dialogSpecificOutlineKeys}) {
    setState(() {
      _activeDialog = dialog;
      _isBlurred = true;
      if (dialogSpecificOutlineKeys != null) {
        activeOutlineKeys.addAll(dialogSpecificOutlineKeys);
        // ignore: avoid_print
        print("Added dialog specific keys: ${dialogSpecificOutlineKeys.keys.toList()}");
      }
      if (dialog is CustomClearDataDialog) {
        // Ensure keys from CustomClearDataDialog are consistently named for removal by prefix.
        activeOutlineKeys['dialog_customcleardata_cancel'] = dialog.cancelOutlineKey;
        activeOutlineKeys['dialog_customcleardata_confirm'] = dialog.confirmOutlineKey;
        // ignore: avoid_print
        print("Added CustomClearDataDialog keys: dialog_customcleardata_cancel, dialog_customcleardata_confirm");
      }
      // TODO(agent): Handle CustomAppActionDialog keys when that dialog is updated to expose its keys.
      // Example: if (dialog is CustomAppActionDialog) { ... add its keys ... }
      // ignore: avoid_print
      print("Current active keys after showing dialog: ${activeOutlineKeys.keys.toList()}");
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