import 'types.dart';

/// Options for encoding to TOON format.
class EncodeOptions {
  /// Number of spaces per indentation level (default: 2).
  final int indent;

  /// Delimiter for array values and tabular rows (default: ',').
  final String delimiter;

  /// Optional marker to prefix array lengths (default: null).
  /// Set to '#' to enable length marker.
  final String? lengthMarker;

  /// Whether to flatten nested objects into a flat map (default: false).
  /// When true, nested objects are converted to flat keys using [flatMapSeparator].
  /// Example: {'a': {'b': 'x'}} becomes {'a_b': 'x'} with separator '_'.
  final bool enforceFlatMap;

  /// Separator to use when flattening nested objects (default: '_').
  /// Only used when [enforceFlatMap] is true.
  final String flatMapSeparator;

  const EncodeOptions({
    this.indent = 2,
    this.delimiter = ',',
    this.lengthMarker,
    this.enforceFlatMap = false,
    this.flatMapSeparator = '_',
  }) : assert(indent > 0, 'indent must be positive');

  /// Resolves encode options with defaults.
  ResolvedEncodeOptions resolve() {
    assert(flatMapSeparator.isNotEmpty, 'flatMapSeparator must not be empty');
    return ResolvedEncodeOptions(
      indent: indent,
      delimiter: delimiter,
      lengthMarker: lengthMarker,
      enforceFlatMap: enforceFlatMap,
      flatMapSeparator: flatMapSeparator,
    );
  }
}

/// Options for decoding from TOON format.
class DecodeOptions {
  /// Expected number of spaces per indentation level (default: 2).
  final int indent;

  /// Enable strict validation (default: true).
  final bool strict;

  /// Whether to unflatten flat map keys back into nested objects (default: false).
  /// When true, flat keys are converted back to nested objects using [flatMapSeparator].
  /// Example: {'a_b': 'x'} becomes {'a': {'b': 'x'}} with separator '_'.
  final bool enforceFlatMap;

  /// Separator used when unflattening flat map keys (default: '_').
  /// Only used when [enforceFlatMap] is true.
  final String flatMapSeparator;

  const DecodeOptions({
    this.indent = 2,
    this.strict = true,
    this.enforceFlatMap = false,
    this.flatMapSeparator = '_',
  }) : assert(indent > 0, 'indent must be positive');

  /// Resolves decode options with defaults.
  ResolvedDecodeOptions resolve() {
    assert(flatMapSeparator.isNotEmpty, 'flatMapSeparator must not be empty');
    return ResolvedDecodeOptions(
      indent: indent,
      strict: strict,
      enforceFlatMap: enforceFlatMap,
      flatMapSeparator: flatMapSeparator,
    );
  }
}
