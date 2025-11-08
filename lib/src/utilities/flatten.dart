import '../types.dart';
import '../encode/normalize.dart';

/// Flattens a nested JSON object into a flat map.
///
/// Example: {'a': {'b': 'x'}} becomes {'a_b': 'x'} with separator '_'.
///
/// [value] The JSON value to flatten
/// [separator] The separator to use between nested keys (default: '_')
/// [prefix] Internal parameter for recursive calls
/// Returns a flattened JsonObject
JsonObject flattenMap(JsonValue value, String separator, [String prefix = '']) {
  if (value == null) {
    return {};
  }

  if (isJsonPrimitive(value)) {
    // If we have a prefix, this is a nested value that needs to be flattened
    if (prefix.isNotEmpty) {
      return {prefix: value};
    }
    // No prefix means this is a root primitive, return empty (can't flatten a primitive)
    return {};
  }

  if (isJsonArray(value)) {
    // Arrays are preserved as-is, but with prefix if needed
    if (prefix.isNotEmpty) {
      return {prefix: value};
    }
    // Root array can't be flattened
    return {};
  }

  if (isJsonObject(value)) {
    final result = <String, JsonValue>{};
    final obj = value as JsonObject;

    for (final entry in obj.entries) {
      final key = entry.key;
      final val = entry.value;

      // Build the new key
      final newKey = prefix.isEmpty ? key : '$prefix$separator$key';

      if (isJsonPrimitive(val)) {
        // Primitive value - add directly
        result[newKey] = val;
      } else if (isJsonArray(val)) {
        // Array - flatten objects within array
        final flattenedArray = (val as JsonArray).map((item) {
          if (isJsonObject(item)) {
            // Flatten nested objects in array (without prefix, as they're array items)
            return flattenMap(item, separator);
          } else if (isJsonArray(item)) {
            // Recursively handle nested arrays
            return (item as JsonArray).map((subItem) {
              if (isJsonObject(subItem)) {
                return flattenMap(subItem, separator);
              }
              return subItem;
            }).toList();
          }
          return item;
        }).toList();
        result[newKey] = flattenedArray;
      } else if (isJsonObject(val)) {
        // Nested object - recursively flatten
        final flattened = flattenMap(val, separator, newKey);
        result.addAll(flattened);
      }
    }

    return result;
  }

  return {};
}

/// Unflattens a flat map back into nested objects.
///
/// Example: {'a_b': 'x'} becomes {'a': {'b': 'x'}} with separator '_'.
///
/// [value] The JSON value to unflatten
/// [separator] The separator used in flat keys (default: '_')
/// Returns an unflattened JsonValue
JsonValue unflattenMap(JsonValue value, String separator) {
  if (value == null) {
    return null;
  }

  if (isJsonPrimitive(value)) {
    return value;
  }

  if (isJsonArray(value)) {
    // Unflatten items in array
    return (value as JsonArray).map((item) => unflattenMap(item, separator)).toList();
  }

  if (isJsonObject(value)) {
    final obj = value as JsonObject;
    final result = <String, JsonValue>{};

    for (final entry in obj.entries) {
      final key = entry.key;
      final val = entry.value;

      // Check if key contains separator
      if (key.contains(separator)) {
        // Split the key
        final parts = key.split(separator);
        if (parts.isEmpty) continue;

        // Build nested structure
        var current = result;
        for (int i = 0; i < parts.length - 1; i++) {
          final part = parts[i];
          if (part.isEmpty) continue;

          if (!current.containsKey(part)) {
            current[part] = <String, JsonValue>{};
          }
          final next = current[part];
          if (isJsonObject(next)) {
            current = next as JsonObject;
          } else {
            // Conflict - key already exists with non-object value
            // Create a new object and move existing value
            final existing = current[part];
            current[part] = <String, JsonValue>{};
            current = current[part] as JsonObject;
            // Try to preserve existing value if possible
            if (existing != null) {
              current['_value'] = existing;
            }
          }
        }

        // Set the final value
        final finalKey = parts.last;
        if (finalKey.isNotEmpty) {
          // Unflatten the value if it's an object or array
          current[finalKey] = unflattenMap(val, separator);
        }
      } else {
        // No separator - add directly (but unflatten value if needed)
        result[key] = unflattenMap(val, separator);
      }
    }

    return result;
  }

  return value;
}

