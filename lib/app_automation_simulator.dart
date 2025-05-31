// File: app_automation_simulator.dart
import 'package:flutter/material.dart';
import 'phone_mockup/phone_mockup_container.dart';
import 'phone_mockup/app_grid.dart';

class AppAutomationSimulator {
  final GlobalKey<PhoneMockupContainerState> phoneMockupKey;
  final GlobalKey<AppGridState> appGridKey;

  AppAutomationSimulator({
    required this.phoneMockupKey,
    required this.appGridKey,
  });

  Future<bool> startClearDataSimulation(String appName) async {
    print("Starting 'clear data' simulation for app: $appName");

    // Ensure we have access to the PhoneMockupContainerState
    final phoneMockupState = phoneMockupKey.currentState;
    if (phoneMockupState == null) {
      print("Error: PhoneMockupContainerState is null. Cannot proceed.");
      return false;
    }

    // Step 1: Simulate scrolling/searching for app
    print("Simulating scrolling/searching for $appName...");
    await Future.delayed(const Duration(seconds: 1)); // Reduced delay

    final appGridState = appGridKey.currentState;
    if (appGridState == null) {
      print("Error: AppGridState is null. Cannot proceed.");
      return false;
    }

    appGridState.scrollToApp(appName);
    print("Scrolled to $appName (or attempted to).");
    await Future.delayed(const Duration(milliseconds: 500)); // Reduced delay

    final appDetails = appGridState.getAppByName(appName);
    if (appDetails == null || appDetails.isEmpty) {
      print("App '$appName' not found in grid after scrolling.");
      return false;
    }

    print("App '$appName' found: $appDetails");
    await Future.delayed(const Duration(milliseconds: 500)); // Reduced delay

    // Step 2: Simulate long press on the app icon
    print("Simulating long press on $appName.");
    if (phoneMockupState.mounted) {
      phoneMockupState.handleAppLongPress(appDetails);
    } else {
      print("Error: PhoneMockupContainerState is not mounted. Cannot simulate long press.");
      return false;
    }

    // Wait for the CustomAppActionDialog to appear
    print("Waiting for app action dialog (long press dialog) to appear.");
    await Future.delayed(const Duration(seconds: 1)); // Give time for the dialog to build

    // *** IMPORTANT FIX HERE ***
    // Step 3: Simulate selecting "App info" and immediately dismiss the CustomAppActionDialog.
    // In a real scenario, the user would tap "App info" within the dialog,
    // which would trigger onActionSelected and then dismiss the dialog.
    // In simulation, we bypass the actual tap on the dialog option and directly
    // navigate and then dismiss the dialog.
    if (phoneMockupState.mounted) {
      // Dismiss the CustomAppActionDialog first
      phoneMockupState.dismissDialog(); // Use the public method to dismiss
      print("Dismissing long press action dialog.");
      await Future.delayed(const Duration(milliseconds: 300)); // Short delay for UI update

      // Now navigate to App Info as if the "App info" option was tapped
      phoneMockupState.navigateToAppInfo(appDetails: appDetails);
      print("Navigating to App Info screen.");
    } else {
      print("Error: PhoneMockupContainerState is not mounted. Cannot dismiss dialog or navigate to App Info.");
      return false;
    }

    // Step 4: Wait on App Info screen
    print("Reviewing App Info screen for 1.5 seconds.");
    await Future.delayed(const Duration(milliseconds: 1500)); // Reduced delay

    // Step 5: Click "Storage & cache" (or similar button to navigate to ClearDataScreen)
    if (phoneMockupState.mounted) {
      phoneMockupState.navigateToStorageUsage();
      print("Simulating click on 'Storage & cache'. Navigating to Clear Data screen.");
    } else {
      print("Error: PhoneMockupContainerState is not mounted. Cannot navigate to Storage Usage.");
      return false;
    }

    // Step 6: Wait on storage screen
    print("Reviewing storage screen for 1.5 seconds.");
    await Future.delayed(const Duration(milliseconds: 1500)); // Reduced delay

    // Step 7: Click Clear Data (which should open CustomClearDataDialog)
    await Future.delayed(const Duration(milliseconds: 500)); // Short delay before clicking
    if (phoneMockupState.mounted) {
      phoneMockupState.simulateClearDataClick(); // This shows CustomClearDataDialog
      print("Simulating click on 'Clear Data'.");
    } else {
      print("Error: PhoneMockupContainerState is not mounted. Cannot simulate Clear Data click.");
      return false;
    }

    // Step 8: Confirm delete (in CustomClearDataDialog)
    print("Waiting 1 second for confirmation dialog.");
    await Future.delayed(const Duration(seconds: 1)); // Give time for clear data dialog

    if (phoneMockupState.mounted) {
      // `simulateConfirmDelete()` in PhoneMockupContainerState already calls _dismissDialog().
      phoneMockupState.simulateConfirmDelete();
      print("Simulating click on 'Delete' in confirmation dialog. Dialog should dismiss.");
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for dialog to dismiss
    } else {
      print("Error: PhoneMockupContainerState is not mounted. Cannot simulate confirm delete.");
      return false;
    }

    // Step 9: Return home
    await Future.delayed(const Duration(seconds: 1)); // Reduced delay
    if (phoneMockupState.mounted) {
      phoneMockupState.navigateHome();
      print("Simulation complete. Returning to home screen.");
    } else {
      print("Error: PhoneMockupContainerState is not mounted. Cannot return home.");
      return false;
    }

    return true;
  }
}