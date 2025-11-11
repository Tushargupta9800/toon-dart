import '../lib/toon_x_json.dart';
import 'json_formatter.dart';

void main() {

  // WHAT's HERE ???

  // JSON -> TOON
  // TOON -> JSON
  // MULTICHILD JSON -> TOON
  // TOON -> MULTICHILD JSON

  // Example: Simple JSON with array of objects (tabular format)
  final data = {
    'users': [
      {'id': 1, 'name': 'Alice', 'role': 'admin'},
      {'id': 2, 'name': 'Bob', 'role': 'user'}
    ]
  };

  final toon = encode(data);
  print('=== Simple JSON Example ===');
  print(toon);
  // Output:
  // users[2]{id,name,role}:
  //   1,Alice,admin
  //   2,Bob,user
  print('');
  
  // Decode it back
  final decoded = decode(toon);
  print('Decoded JSON:');
  printJson(decoded);
  // Output:
  // {
  //   "users": [
  //     {
  //       "id": 1.0,
  //       "name": "Alice",
  //       "role": "admin"
  //     },
  //     {
  //       "id": 2.0,
  //       "name": "Bob",
  //       "role": "user"
  //     }
  //   ]
  // }
  print('');
  
  // Example: Flat Map - Simple nested object
  print('=== Flat Map Example ===');
  final nested = {
    'a': {
      'b': 'x',
      'c': 42,
    }
  };
  
  print('Original nested object:');
  printJson(nested);
  // Output:
  // {
  //   "a": {
  //     "b": "x",
  //     "c": 42
  //   }
  // }
  print('');
  
  // Encode with flat map
  final toonFlat = encode(nested, options: EncodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('TOON (flattened):');
  print(toonFlat);
  // Output:
  // a_b: x
  // a_c: 42
  print('');
  
  // Decode with unflattening
  final decodedFlat = decode(toonFlat, options: DecodeOptions(
    enforceFlatMap: true,
    flatMapSeparator: '_',
  ));
  print('Decoded (unflattened back to original):');
  printJson(decodedFlat);
  // Output:
  // {
  //   "a": {
  //     "b": "x",
  //     "c": 42.0
  //   }
  // }
}
