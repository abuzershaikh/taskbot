// File: tool_drawer.dart
import 'package:taskbot/app_automation_simulator.dart';
import 'package:flutter/material.dart';
import 'phone_mockup/app_grid.dart'; // Import for AppGridState
import 'phone_mockup/phone_mockup_container.dart'; // Import for PhoneMockupContainerState
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ToolDrawer extends StatefulWidget {
  final File? pickedImage;
  final Function(File?) onImageChanged;
  final Function(double, double) onImagePan;
  final Function(double) onImageScale;
  final VoidCallback onClose;
  final double currentImageScale;
  final GlobalKey<PhoneMockupContainerState> phoneMockupKey; // NEW
  final GlobalKey<AppGridState> appGridKey; // NEW

  const ToolDrawer({
    super.key,
    required this.pickedImage,
    required this.onImageChanged,
    required this.onImagePan,
    required this.onImageScale,
    required this.onClose,
    required this.currentImageScale,
    required this.phoneMockupKey, // NEW
    required this.appGridKey, // NEW
  });

  @override
  State<ToolDrawer> createState() => ToolDrawerState();
}

class ToolDrawerState extends State<ToolDrawer> {
  late TextEditingController _commandController;
  late AppAutomationSimulator _appAutomationSimulator;
  bool _isSimulationRunning = false; // New state variable

  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController();
    _appAutomationSimulator = AppAutomationSimulator(
      phoneMockupKey: widget.phoneMockupKey,
      appGridKey: widget.appGridKey,
    );
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  // Method to parse the command
  Map<String, String>? _parseCommand(String command) {
    final lowerCaseCommand = command.toLowerCase();
    if (lowerCaseCommand.contains('clear data')) {
      // Find the index of "clear data"
      final clearDataIndex = lowerCaseCommand.indexOf('clear data');
      if (clearDataIndex > 0) { // Ensure "clear data" is not at the beginning
        final appName = command.substring(0, clearDataIndex).trim();
        if (appName.isNotEmpty) {
          return {'appName': appName, 'action': 'clearData'};
        }
      }
    }
    return null;
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.onImageChanged(File(image.path)); // Notify parent
      widget.onClose(); // Close drawer after action
    }
  }

  // Function to dismiss the image
  void _dismissImage() {
    widget.onImageChanged(null); // Notify parent
    widget.onClose(); // Close drawer after action
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Make Material transparent
      child: Align(
        alignment: Alignment.centerRight, // Align drawer to the right
        child: Container(
          width: 200, // Width of your tool drawer
          height: double.infinity, // Take full height
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Semi-transparent white background
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(-5, 0), // Shadow on the left side
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 30, thickness: 1),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Image'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.pickedImage != null)
                  ElevatedButton.icon(
                    onPressed: _dismissImage,
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove Image'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Image Controls:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Scale:'),
                    SizedBox(
                      width: 100, // Give it a fixed width
                      child: Slider(
                        value: widget.currentImageScale, // FIX: Use the actual current scale
                        min: 0.1,
                        max: 5.0,
                        divisions: 49,
                        onChanged: (double value) {
                          widget.onImageScale(value); // FIX: Call the parent's scale callback
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => widget.onImagePan(-10.0, 0.0), // Move left
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => widget.onImagePan(10.0, 0.0), // Move right
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () => widget.onImagePan(0.0, -10.0), // Move up
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => widget.onImagePan(0.0, 10.0), // Move down
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Spacing before command input
                const Text(
                  'Command Input:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _commandController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter command',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: _isSimulationRunning ? null : _handleRunCommand, // Updated onPressed
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: _isSimulationRunning ? Colors.grey : null, // Optional: visual feedback
                    ),
                    child: Text(_isSimulationRunning ? 'Simulating...' : 'Run Command'), // Updated text
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRunCommand() async {
    if (_isSimulationRunning) {
      // Optional: Show a SnackBar if trying to run while already running
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Simulation already in progress."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSimulationRunning = true;
      });
    }

    try {
      final commandText = _commandController.text;
      final parsedCommand = _parseCommand(commandText);

      if (parsedCommand != null) {
        final appName = parsedCommand['appName'];
        final action = parsedCommand['action'];

        if (action == 'clearData' && appName != null) {
          widget.onClose(); // Close the drawer
          await Future.delayed(const Duration(milliseconds: 300)); // Allow drawer to close

          final bool simulationSucceeded = await _appAutomationSimulator.startClearDataSimulation(appName);
          
          if (!simulationSucceeded && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: App '$appName' not found or simulation failed."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // ignore: avoid_print
          print('Parsed command: $parsedCommand, but action or appName is invalid for simulation.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid command format for simulation."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        // ignore: avoid_print
        print('Invalid command.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid command: Could not parse."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSimulationRunning = false;
        });
      }
    }
  }
}