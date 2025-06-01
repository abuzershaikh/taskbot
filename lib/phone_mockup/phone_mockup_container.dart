 
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
import 'clickable_outline.dart'; // Required for GlobalKey<ClickableOutlineState>

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

  // --- AppInfoScreen Keys ---
  final GlobalKey<ClickableOutlineState> _appInfoBackButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoOpenButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoStorageCacheButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoMobileDataKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoBatteryKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoNotificationsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoPermissionsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoOpenByDefaultKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoUninstallButtonKey = GlobalKey();

  // --- ClearDataScreen Keys ---
  final GlobalKey<ClickableOutlineState> _clearDataBackButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataClearDataButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataClearCacheButtonKey = GlobalKey();

  // --- CustomAppActionDialog Keys ---
  final GlobalKey<ClickableOutlineState> _appActionDialogAppInfoKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appActionDialogUninstallKey = GlobalKey();
  // final GlobalKey<ClickableOutlineState> _appActionDialogForceStopKey = GlobalKey(); // Not implemented in dialog

  // --- CustomClearDataDialog Keys ---
  final GlobalKey<ClickableOutlineState> _clearDataDialogCancelKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataDialogConfirmKey = GlobalKey();

  void dismissDialog() {
    setState(() {
      _activeDialog = null;
      _isBlurred = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentScreenWidget(); // Initialize with AppGrid
  }

  void _updateCurrentScreenWidget() {
    switch (_currentScreenView) {
      case CurrentScreenView.appGrid:
        _currentAppScreenWidget = AppGrid(
          key: widget.appGridKey,
          phoneMockupKey: widget.key as GlobalKey<PhoneMockupContainerState>,
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
            onNavigateToClearData: (appData) {
              navigateToStorageUsage();
            },
            showDialog: _showDialog,
            dismissDialog: dismissDialog,
            // Pass all the keys to AppInfoScreen
            backButtonKey: _appInfoBackButtonKey,
            openButtonKey: _appInfoOpenButtonKey,
            storageCacheButtonKey: _appInfoStorageCacheButtonKey,
            mobileDataKey: _appInfoMobileDataKey,
            batteryKey: _appInfoBatteryKey,
            notificationsKey: _appInfoNotificationsKey,
            permissionsKey: _appInfoPermissionsKey,
            openByDefaultKey: _appInfoOpenByDefaultKey,
            uninstallButtonKey: _appInfoUninstallButtonKey,
          );
        } else {
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
            dismissDialog: dismissDialog,
            onPerformClearData: () => _performActualDataClear(_currentAppDetails!['name']!),
            onPerformClearCache: () => _performActualCacheClear(_currentAppDetails!['name']!),
            backButtonKey: _clearDataBackButtonKey,
            clearDataButtonKey: _clearDataClearDataButtonKey,
            clearCacheButtonKey: _clearDataClearCacheButtonKey,
            // Pass dialog keys for CustomClearDataDialog shown by ClearDataScreen
            dialogCancelKey: _clearDataDialogCancelKey,
            dialogConfirmKey: _clearDataDialogConfirmKey,
          );
        } else {
          _currentScreenView = CurrentScreenView.appGrid;
          _updateCurrentScreenWidget();
        }
        break;
    }
  }

  Future<void> _handleCommand(String command) async {
    final cmd = command.toLowerCase().trim();
    if (cmd.contains('settings')) {
      _handleAppTap('Settings');
    } else if (cmd.startsWith('long press ')) {
      final appName = cmd.substring('long press '.length).trim();
      final appDetails = widget.appGridKey.currentState?.getAppByName(appName);
      if (appDetails != null && appDetails.isNotEmpty) {
        handleAppLongPress(appDetails);
      } else {
        // ignore: avoid_print
        print('PhoneMockupContainer: App for programmatic long press "$appName" not found.');
      }
    } else if (cmd.startsWith('tap ')) {
      final appName = cmd.substring('tap '.length).trim();
      _handleAppTap(appName);
    } else if (cmd.contains('back')) {
      // Prioritize programmatic back if available for the current screen
      if (_currentScreenView == CurrentScreenView.appInfo) {
        await triggerAppInfoBackButtonAction();
      } else if (_currentScreenView == CurrentScreenView.clearData) {
        await triggerClearDataBackButtonAction();
      } else if (_currentScreenView == CurrentScreenView.settings) {
         setState(() { // Settings back is simpler, no key needed for it yet.
          _currentScreenView = CurrentScreenView.appGrid;
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
        navigateToAppInfo(appDetails: Map<String, String>.from(appDetails));
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
    print('PhoneMockupContainer: User long press on app: ${app['name']}');
    _currentAppDetails = Map<String, String>.from(app);
    _showCustomAppActionDialog(_currentAppDetails!);
  }

  void _showCustomAppActionDialog(Map<String, String> appDetails) {
    setState(() {
      _isBlurred = true;
      _activeDialog = CustomAppActionDialog(
        app: appDetails,
        onActionSelected: (actionName, appDetailsFromDialog) {
          dismissDialog(); // This is important, dialog should be dismissed by its internal logic
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
        // Pass keys for dialog elements
        appInfoKey: _appActionDialogAppInfoKey,
        uninstallKey: _appActionDialogUninstallKey,
        // forceStopKey: _appActionDialogForceStopKey, // If it were implemented
      );
    });
  }

  void navigateToAppInfo({Map<String, String>? appDetails}) {
    final detailsToUse = appDetails ?? _currentAppDetails;

    if (detailsToUse != null) {
      if (_currentAppDetails != detailsToUse) {
         _currentAppDetails = detailsToUse;
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
        if (_currentScreenView == CurrentScreenView.clearData) _updateCurrentScreenWidget();
      });
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data cleared for $appName')));
    }
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
        if (_currentScreenView == CurrentScreenView.clearData) _updateCurrentScreenWidget();
      });
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cache cleared for $appName')));
    }
  }

  // --- Methods to trigger ClickableOutline actions ---
  Future<void> triggerAppInfoStorageCacheAction() async {
    await _appInfoStorageCacheButtonKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerAppInfoBackButtonAction() async {
    await _appInfoBackButtonKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerClearDataButtonAction() async {
    // This action in ClearDataScreen shows an AlertDialog, not CustomClearDataDialog.
    // The requirement is to add keys to CustomClearDataDialog.
    // So, this trigger is for the button on ClearDataScreen.
    await _clearDataClearDataButtonKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerClearCacheButtonAction() async {
    await _clearDataClearCacheButtonKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerClearDataBackButtonAction() async {
    await _clearDataBackButtonKey.currentState?.triggerOutlineAndAction();
  }

  // Methods for Dialogs
  Future<void> triggerDialogAppInfoAction() async {
    await _appActionDialogAppInfoKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerDialogUninstallAction() async {
    await _appActionDialogUninstallKey.currentState?.triggerOutlineAndAction();
  }

  // Force Stop is not in CustomAppActionDialog currently.
  // Future<void> triggerDialogForceStopAction() async {
  //   await _appActionDialogForceStopKey.currentState?.triggerOutlineAndAction();
  // }

  Future<void> triggerDialogClearDataConfirmAction() async {
    await _clearDataDialogConfirmKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerDialogClearDataCancelAction() async {
    await _clearDataDialogCancelKey.currentState?.triggerOutlineAndAction();
  }
  // --- End Trigger Methods ---


  void simulateClearDataClick() {
    // This method is supposed to simulate clicking the "Clear Data" button
    // which then shows a dialog. If the "Clear Data" button on ClearDataScreen
    // shows the CustomClearDataDialog, then this method should trigger that.
    // However, ClearDataScreen's "Clear Data" button shows a standard AlertDialog.
    // CustomClearDataDialog was only used in the old simulateClearDataClick.
    // For now, let's assume simulateClearDataClick is meant to show *CustomClearDataDialog*
    // and make it use the new keys.
    if (_currentAppDetails != null) { // No need to be on ClearData screen to simulate this.
      final String appName = _currentAppDetails!['name']!;
      // ignore: avoid_print
      print("PhoneMockupContainer: simulateClearDataClick for $appName - showing CustomClearDataDialog with keys.");
      _showDialog(
        CustomClearDataDialog(
          title: 'Clear app data?',
          content: 'This app\'s data, including files and settings, will be permanently deleted from this device.',
          confirmButtonText: 'Delete',
          confirmButtonColor: Colors.red,
          onConfirm: () {
            dismissDialog();
            _performActualDataClear(appName);
          },
          onCancel: dismissDialog,
          // Pass keys to CustomClearDataDialog
          cancelKey: _clearDataDialogCancelKey,
          confirmKey: _clearDataDialogConfirmKey,
        ),
      );
    } else {
      // ignore: avoid_print
      print("PhoneMockupContainer: Error - No app selected for simulateClearDataClick (CustomClearDataDialog).");
    }
  }


  void simulateConfirmDelete() {
    // This method is intended to confirm whatever dialog is currently active,
    // assuming it's a confirmation dialog for deletion.
    if (_activeDialog != null && _currentAppDetails != null) {
      // If the active dialog is our CustomClearDataDialog, we can trigger its confirm action.
      // Otherwise, this simulation might be too generic.
      // For now, assume it's for the CustomClearDataDialog if it's active.
      // ignore: avoid_print
      print("PhoneMockupContainer: Simulating confirm delete on active dialog.");
      // We don't call dismissDialog() here because the dialog's own action should handle it.
      triggerDialogClearDataConfirmAction();
    } else {
      // ignore: avoid_print
      print("PhoneMockupContainer: Error - No active dialog or no app details for simulateConfirmDelete.");
    }
  }

  void navigateHome() {
    setState(() {
      _currentScreenView = CurrentScreenView.appGrid;
      _currentAppDetails = null;
      dismissDialog();
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
              Positioned.fill(
                top: 31,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.0),
                  ),
                ),
              ),
            if (_activeDialog != null)
              Positioned.fill(
                top: 31,
                child: GestureDetector(
                  onTap: dismissDialog,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
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