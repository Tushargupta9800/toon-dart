import '../lib/toon_x_json.dart';
import 'json_formatter.dart';

void main() {
  print('=== 9. Flat Map Examples ===\n');
  
  // Example 1: Simple nested object
  print('Example 1: Simple nested object');
  final nested = {
    'a': {
      'b': 'x',
      'c': 42,
    }
  };
  
  print('Original:');
  printJson(nested);
  print('');
  
  // Encode with flat map
  final toonFlat = encode(nested, options: EncodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('TOON (flattened):');
  print(toonFlat);
  print('');
  
  // Decode with unflattening
  final decodedFlat = decode(toonFlat, options: DecodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('Decoded (unflattened):');
  printJson(decodedFlat);
  print('');
  
  // Example 2: Deeply nested
  print('Example 2: Deeply nested object');
  final deepNested = {
    'user': {
      'profile': {
        'name': 'Alice',
        'settings': {
          'theme': 'dark',
          'notifications': true,
        }
      },
      'id': 1,
    }
  };
  
  print('Original:');
  printJson(deepNested);
  print('');
  
  final toonDeep = encode(deepNested, options: EncodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('TOON (flattened):');
  print(toonDeep);
  print('');
  
  final decodedDeep = decode(toonDeep, options: DecodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('Decoded (unflattened):');
  printJson(decodedDeep);
  print('');
  
  // Example 3: Custom separator
  print('Example 3: Custom separator (using ".")');
  final custom = {
    'config': {
      'database': {
        'host': 'localhost',
        'port': 5432,
      }
    }
  };
  
  print('Original:');
  printJson(custom);
  print('');
  
  final toonCustom = encode(custom, options: EncodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '.',
  ));
  print('TOON (flattened with "." separator):');
  print(toonCustom);
  print('');
  
  final decodedCustom = decode(toonCustom, options: DecodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '.',
  ));
  print('Decoded (unflattened):');
  printJson(decodedCustom);
  print('');
  
  // Example 4: With arrays
  print('Example 4: Nested object with arrays');
  final withArrays = {
    'users': [
      {
        'id': 1,
        'profile': {
          'name': 'Alice',
          'tags': ['admin', 'dev'],
        }
      },
      {
        'id': 2,
        'profile': {
          'name': 'Bob',
          'tags': ['user'],
        }
      }
    ]
  };
  
  print('Original:');
  printJson(withArrays);
  print('');
  
  final toonArrays = encode(withArrays, options: EncodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('TOON (flattened):');
  print(toonArrays);
  print('');
  
  final decodedArrays = decode(toonArrays, options: DecodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('Decoded (unflattened):');
  printJson(decodedArrays);
  print('');
  
  // Example 5: Without flat map (normal behavior)
  print('Example 5: Without flat map (normal behavior)');
  final normal = {
    'a': {
      'b': 'x',
    }
  };
  
  final toonNormal = encode(normal);
  print('TOON (normal, not flattened):');
  print(toonNormal);
  print('');
  
  final decodedNormal = decode(toonNormal);
  print('Decoded (normal):');
  printJson(decodedNormal);
}

