/// Token-Oriented Object Notation (TOON) encoder and decoder for Dart.
///
/// TOON is a compact, human-readable format designed for passing structured
/// data to Large Language Models with significantly reduced token usage.
///
/// This package is currently under development.
/// For specification, see: https://github.com/johannschopplich/toon/blob/main/SPEC.md
library toon_format;

/// Encodes a value to TOON format.
///
/// Currently not implemented.
String encode(dynamic value, {Map<String, dynamic>? options}) {
  throw UnimplementedError('TOON encoding is not yet implemented');
}

/// Decodes a TOON-formatted string to a Dart value.
///
/// Currently not implemented.
dynamic decode(String input, {Map<String, dynamic>? options}) {
  throw UnimplementedError('TOON decoding is not yet implemented');
}
