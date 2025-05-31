// File: lib/phone_mockup/custom_clear_data_dialog.dart
import 'package:flutter/material.dart';
import 'clickable_outline.dart'; // Import ClickableOutline

class CustomClearDataDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final Color confirmButtonColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  // Add GlobalKeys for ClickableOutline
  final GlobalKey<ClickableOutlineState> cancelOutlineKey = GlobalKey<ClickableOutlineState>();
  final GlobalKey<ClickableOutlineState> confirmOutlineKey = GlobalKey<ClickableOutlineState>();

  CustomClearDataDialog({ // Modified constructor to remove const
    super.key,
    required this.title,
    required this.content,
    required this.confirmButtonText,
    this.confirmButtonColor = Colors.red, // Default to red for delete/clear
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog( // Use AlertDialog for a standard dialog appearance
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
      actions: [
        ClickableOutline(
          key: cancelOutlineKey,
          onTap: onCancel,
          child: TextButton(
            onPressed: onCancel, // onPressed is still needed for TextButton's own behavior
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        ClickableOutline(
          key: confirmOutlineKey,
          onTap: onConfirm,
          child: TextButton(
            onPressed: onConfirm, // onPressed is still needed for TextButton's own behavior
            child: Text(
              confirmButtonText,
              style: TextStyle(color: confirmButtonColor),
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Apply border radius to the dialog itself
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0), // Adjust padding for content
      actionsPadding: const EdgeInsets.all(8.0), // Adjust padding for actions
    );
  }
}