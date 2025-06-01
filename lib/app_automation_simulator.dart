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

    // Step 2: Simulate long press on the app icon using ClickableOutline
    print("Simulating long press on $appName via ClickableOutline.");
    final appOutlineKey = appGridState.getKeyForApp(appName);
    if (appOutlineKey == null) {
      print("Error: Could not find ClickableOutline key for app $appName.");
      return false;
    }
    if (appOutlineKey.currentState == null) {
      print("Error: ClickableOutline key for $appName has no current state.");
      return false;
    }
    await appOutlineKey.currentState!.triggerOutlineAndAction();
    // The 5-second delay is now part of triggerOutlineAndAction.
    // The action itself (handleAppLongPress) shows the dialog.
    print("Long press action triggered for $appName. Waiting for dialog.");
    await Future.delayed(const Duration(milliseconds: 700)); // Wait for dialog to build/appear after action.

    // Step 3: Simulate selecting "App info" in the dialog using ClickableOutline
    print("Simulating selection of 'App info' in dialog via ClickableOutline.");
    if (!phoneMockupState.mounted) {
      print("Error: PhoneMockupContainerState is not mounted. Cannot trigger dialog action.");
      return false;
    }
    await phoneMockupState.triggerDialogAppInfoAction();
    // triggerDialogAppInfoAction includes the outline delay and performs navigation.
    print("'App info' action triggered. Waiting for navigation to App Info screen.");
    await Future.delayed(const Duration(milliseconds: 300)); // Short delay for screen transition.

    // Step 4: Wait on App Info screen (user thinking time)
    print("Reviewing App Info screen for 1.5 seconds.");
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 5: Click "Storage & cache" using ClickableOutline
    print("Simulating click on 'Storage & cache' via ClickableOutline.");
    if (!phoneMockupState.mounted) {
      print("Error: PhoneMockupContainerState is not mounted. Cannot trigger 'Storage & cache' action.");
      return false;
    }
    await phoneMockupState.triggerAppInfoStorageCacheAction();
    // triggerAppInfoStorageCacheAction includes outline delay and navigates to ClearDataScreen.
    print("'Storage & cache' action triggered. Waiting for navigation to Clear Data screen.");
    await Future.delayed(const Duration(milliseconds: 300)); // Short delay for screen transition.

    // Step 6: Wait on storage screen (user thinking time)
    print("Reviewing storage screen for 1.5 seconds.");
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 7: Click "Clear Data" using ClickableOutline
    print("Simulating click on 'Clear Data' via ClickableOutline.");
    if (!phoneMockupState.mounted) {
      print("Error: PhoneMockupContainerState is not mounted. Cannot trigger 'Clear Data' action.");
      return false;
    }
    await phoneMockupState.triggerClearDataButtonAction();
    // triggerClearDataButtonAction includes outline delay and its action shows the confirmation dialog.
    print("'Clear Data' action triggered. Waiting for confirmation dialog.");
    await Future.delayed(const Duration(milliseconds: 700)); // Wait for dialog to build/appear.

    // Step 8: Confirm "Delete" in Clear Data Dialog using ClickableOutline
    print("Simulating click on 'Delete' in confirmation dialog via ClickableOutline.");
    if (!phoneMockupState.mounted) {
      print("Error: PhoneMockupContainerState is not mounted. Cannot trigger dialog 'Delete' action.");
      return false;
    }
    await phoneMockupState.triggerDialogClearDataConfirmAction();
    // triggerDialogClearDataConfirmAction includes outline delay and performs data clear + dialog dismissal.
    print("'Delete' action triggered. Waiting for dialog dismissal and data clear operation.");
    await Future.delayed(const Duration(milliseconds: 500)); // Short delay for action to complete.

    // Step 9: Return home
    print("Simulation actions complete. Returning to home screen.");
    await Future.delayed(const Duration(seconds: 1)); // User pause before final navigation.
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