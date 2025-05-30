// File: lib/phone_mockup/clickable_outline.dart
import 'package:flutter/material.dart';

class ClickableOutline extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration outlineDuration; // How long the outline stays visible

  // Add a GlobalKey to allow external triggering
  // This key is passed directly in the constructor where the widget is instantiated.
  const ClickableOutline({
    super.key, // Use the key passed to the constructor as the widget's key
    required this.child,
    this.onTap,
    this.onLongPress,
    this.outlineDuration = const Duration(seconds: 5), // Default duration is 5 seconds
  });

  @override
  State<ClickableOutline> createState() => ClickableOutlineState();
}

class ClickableOutlineState extends State<ClickableOutline> {
  bool _showOutline = false;

  // Public method to trigger the outline and then execute an action.
  // This is used for programmatic triggers (commands).
  Future<void> triggerOutlineAndAction(VoidCallback action) async {
    // Only show outline if not already visible (to prevent multiple triggers)
    if (!_showOutline) {
      setState(() {
        _showOutline = true;
      });
      await Future.delayed(widget.outlineDuration); // Wait for the outline to be visible
      if (mounted) {
        setState(() {
          _showOutline = false;
        });
        action.call(); // Perform the actual action after outline is hidden
      }
    } else {
      // If outline is already showing, just perform the action immediately
      // or implement a different behavior if needed (e.g., extend timer)
      action.call();
    }
  }

  // Handle direct user tap (manual click)
  void _handleTap() {
    triggerOutlineAndAction(widget.onTap ?? () {}); // Pass the original onTap as the action
  }

  // Handle direct user long press (manual click)
  void _handleLongPress() {
    triggerOutlineAndAction(widget.onLongPress ?? () {}); // Pass the original onLongPress as the action
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      child: Stack(
        children: [
          widget.child,
          if (_showOutline)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}