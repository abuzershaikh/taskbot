// Defines the interface for command handlers and specific implementations.

// Abstract base class for all sub-command handlers.
abstract class SubCommandHandler {
  /// Executes the command.
  /// [payload] is the string payload associated with the command.
  /// Returns a Map with 'status' ('success' or 'failed') and 'result_payload' (any string result).
  Future<Map<String, String>> execute(String payload);
}

// Example implementation for a "say_hello" command.
class SayHelloSubCommandHandler implements SubCommandHandler {
  @override
  Future<Map<String, String>> execute(String payload) async {
    // Simulate some work or interaction
    print('Flutter (SayHelloSubCommandHandler): Executing say_hello. Payload: "$payload"');
    
    // Perform the action for "say_hello"
    // For example, just log to console and return a success message.
    String message = 'Flutter executed say_hello successfully.';
    if (payload.isNotEmpty) {
      message += ' Received payload: "$payload"';
    }

    // Simulate a short delay as if doing real work
    await Future.delayed(const Duration(milliseconds: 100));

    return {
      'status': 'success',
      'result_payload': message,
    };
  }
}

// Example of another handler for a potential "echo" command
class EchoSubCommandHandler implements SubCommandHandler {
  @override
  Future<Map<String, String>> execute(String payload) async {
    print('Flutter (EchoSubCommandHandler): Executing echo. Payload: "$payload"');
    
    // Simply echo the payload back
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate work

    return {
      'status': 'success',
      'result_payload': 'Echo: $payload',
    };
  }
}

// Add more command handlers here as needed by subclassing SubCommandHandler.
