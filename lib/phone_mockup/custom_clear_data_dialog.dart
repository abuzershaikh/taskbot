// File: lib/phone_mockup/custom_clear_data_dialog.dart
import 'package:flutter/material.dart';

class CustomClearDataDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final Color confirmButtonColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomClearDataDialog({
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
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmButtonText,
            style: TextStyle(color: confirmButtonColor),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Apply border radius to the dialog itself
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0), // Adjust padding for content
      actionsPadding: const EdgeInsets.all(8.0), // Adjust padding for actions
    );
  }
}