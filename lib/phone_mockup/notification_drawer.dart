import 'package:flutter/material.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => NotificationDrawerState();
}

class NotificationDrawerState extends State<NotificationDrawer> {
  double _drawerHeight = 0.0; // Current height of the drawer, 0.0 means fully closed
  bool _isDragging = false;
  double _dragStartDy = 0.0; // Y-coordinate where the drag started

  // Constants for drawer heights
  static const double _closedHeight = 0.0;
  static const double _halfOpenHeightFraction = 0.5; // Half of phone height
  static const double _fullOpenHeightFraction = 1.0; // Full phone height

  // Get the phone mockup's height for calculation (assuming 600px as defined in PhoneMockupContainer)
  // It's crucial this matches your PhoneMockupContainer's height
  static const double phoneMockupHeight = 600.0;

  void openDrawer() {
    setState(() {
      _drawerHeight = phoneMockupHeight * _halfOpenHeightFraction; // Open to half
    });
  }

  void closeDrawer() {
    setState(() {
      _drawerHeight = _closedHeight; // Close it
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartDy = details.globalPosition.dy;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final double delta = details.globalPosition.dy - _dragStartDy;
    double newHeight = _drawerHeight + delta; // Dragging down increases height

    // Clamp the new height between 0 and full phone height
    _drawerHeight = newHeight.clamp(
      _closedHeight,
      phoneMockupHeight * _fullOpenHeightFraction,
    );

    _dragStartDy = details.globalPosition.dy; // Update drag start for next update

    setState(() {}); // Rebuild to reflect the new height
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;

    final double halfPoint = phoneMockupHeight * _halfOpenHeightFraction;
    final double fullPoint = phoneMockupHeight * _fullOpenHeightFraction;

    if (details.primaryVelocity != null) {
      // If dragged quickly
      if (details.primaryVelocity! < -500) { // Swiping up fast
        if (_drawerHeight > halfPoint) {
            _drawerHeight = halfPoint; // If moving up from full, go to half
        } else {
            closeDrawer(); // If moving up from half or less, close
        }
      } else if (details.primaryVelocity! > 500) { // Swiping down fast
        if (_drawerHeight < halfPoint) {
            _drawerHeight = halfPoint; // If moving down from closed, go to half
        } else {
            _drawerHeight = fullPoint; // If moving down from half, go to full
        }
      } else {
        // If dragged slowly, snap to nearest valid position
        if (_drawerHeight < halfPoint * 0.75) { // If less than 75% of half
            closeDrawer(); // Snap to closed
        } else if (_drawerHeight < fullPoint * 0.75) { // If less than 75% of full
            _drawerHeight = halfPoint; // Snap to half
        } else {
            _drawerHeight = fullPoint; // Snap to full
        }
      }
    } else {
       // No velocity, just snap to nearest based on current position
        if (_drawerHeight < halfPoint * 0.75) {
            closeDrawer();
        } else if (_drawerHeight < fullPoint * 0.75) {
            _drawerHeight = halfPoint;
        } else {
            _drawerHeight = fullPoint;
        }
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300), // Animate only when not dragging
      curve: Curves.easeOut,
      top: 0, // Always start at the top of its parent (the Stack)
      left: 0,
      right: 0,
      height: _drawerHeight, // Animate its height to show/hide
      child: GestureDetector(
        // The GestureDetector should cover the whole AnimatedPositioned area
        // Its onTap should close the drawer if it's open and not fully closed
        onTap: _drawerHeight > _closedHeight + 10.0 ? closeDrawer : null, // Add a small buffer to avoid closing on initial tap
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Container(
          // Dim background when drawer is open, calculated dynamically
          color: _drawerHeight > _closedHeight
              ? Colors.black.withOpacity(0.3 * (_drawerHeight / phoneMockupHeight).clamp(0.0, 1.0))
              : Colors.transparent,
          // Use a Column here to ensure the actual drawer content is also aligned to top
          child: Column(
            children: [
              // This is the actual draggable content container.
              // Use ClipRRect to ensure content doesn't overflow its rounded corners
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0), // Rounded corners at the bottom
                  bottomRight: Radius.circular(20.0),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF0F0F0), // Light grey background like in the image
                  // Limit the height of the content container to the drawer's current height,
                  // subtracting any fixed elements like the handle if needed.
                  height: _drawerHeight > _closedHeight ? _drawerHeight : 0, // Only give height if drawer is open

                  child: SingleChildScrollView(
                    // physics: is determined by the drawer's open state
                    physics: _drawerHeight >= phoneMockupHeight * _halfOpenHeightFraction
                        ? const AlwaysScrollableScrollPhysics() // Enable scrolling when half or full open
                        : const NeverScrollableScrollPhysics(), // Disable scrolling otherwise
                    child: Column( // Use a Column for the actual drawer content
                      children: [
                        // Handle for dragging the drawer
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // Date and Time
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "3:24 Thu, 22 May",
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings, size: 20, color: Colors.black54),
                                onPressed: () {
                                  // print("Settings icon tapped in drawer");
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Settings (Wi-Fi, Mobile Data, etc.)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickSettingTile(Icons.wifi, "Wi-Fi", isActive: true, trailingText: "Off"),
                                  const SizedBox(width: 10),
                                  _buildQuickSettingTile(Icons.data_usage, "Mobile d..", isActive: true),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickSettingIcon(Icons.search, "Search", isActive: false),
                                  _buildQuickSettingIcon(Icons.volume_off, "Mute", isActive: true),
                                  _buildQuickSettingIcon(Icons.bluetooth, "Bluetooth", isActive: false),
                                  _buildQuickSettingIcon(Icons.flash_on, "Flash", isActive: false),
                                  _buildQuickSettingIcon(Icons.location_on, "Location", isActive: false),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Brightness Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.wb_sunny_outlined, color: Colors.grey),
                              Expanded(
                                child: Slider(
                                  value: 0.5,
                                  min: 0,
                                  max: 1,
                                  onChanged: (value) {
                                    // print("Brightness: $value");
                                  },
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.grey[300],
                                ),
                              ),
                              const Icon(Icons.wb_sunny, color: Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Silent notifications section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Silent notifications",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // print("Dismiss silent notifications");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Notifications (example list)
                        _buildNotificationTile(
                          Icons.settings,
                          "System UI",
                          "USB tethering turned on",
                          "0s",
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationTile(
                          Icons.charging_station,
                          "System UI",
                          "Charging Complete",
                          "31m",
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationTile(
                          Icons.android_outlined,
                          "System UI",
                          "USB debugging enab...",
                          "32m",
                        ),
                        const SizedBox(height: 8),

                        // Close Button at the bottom
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: closeDrawer, // Directly call closeDrawer
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 24, color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods remain the same
  Widget _buildQuickSettingTile(IconData icon, String title, {bool isActive = false, String? trailingText}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // print("$title tapped!");
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[600] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: isActive ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: TextStyle(
                    color: isActive ? Colors.white70 : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSettingIcon(IconData icon, String tooltip, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        // print("$tooltip icon tapped!");
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[600] : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black87,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(IconData icon, String appName, String message, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}