import 'package:toon_format/toon_format.dart';

void main() {
  // Example usage (not yet implemented)

  try {
    final data = {
      'users': [
        {'id': 1, 'name': 'Alice', 'role': 'admin'},
        {'id': 2, 'name': 'Bob', 'role': 'user'}
      ]
    };

    // This will throw UnimplementedError
    final toon = encode(data);
    print(toon);
  } catch (e) {
    print('Encoding not yet implemented: $e');
  }
}
