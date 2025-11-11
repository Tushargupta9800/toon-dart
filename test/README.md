# TOON Format Conformance Tests

This directory contains conformance tests that validate the Dart implementation against the [TOON specification test fixtures](https://github.com/toon-format/spec/tree/main/tests).

## Important Note

**⚠️ If new test cases are added to the TOON specification**, you must first update `test/download_fixtures.dart` to include the new fixture file names before running the download script. This ensures all test fixtures are properly downloaded and available for testing.

## Setup

Before running tests, download the test fixtures from the spec repository:

```bash
dart run test/download_fixtures.dart
```

This will download all test fixtures to `test/fixtures/`.

## Running Tests

Run all conformance tests:

```bash
dart test test/conformance_test.dart
```

Or using fvm:

```bash
fvm dart test test/conformance_test.dart
```

## Test Coverage

The conformance tests cover:

### Encode Tests
- ✅ **Primitives** - strings, numbers, booleans, null
- ✅ **Objects** - simple and nested objects
- ✅ **Arrays - Primitive** - arrays of primitive values
- ✅ **Arrays - Tabular** - uniform arrays of objects
- ✅ **Arrays - Nested** - nested array structures
- ✅ **Arrays - Objects** - arrays containing objects
- ✅ **Delimiters** - comma, tab, and pipe delimiters
- ✅ **Options** - indentation, length markers, etc.
- ✅ **Whitespace** - whitespace handling in encoding

### Decode Tests
- ✅ **Numbers** - number parsing and formatting
- ✅ **Primitives** - parsing strings, numbers, booleans, null
- ✅ **Objects** - simple and nested objects
- ✅ **Arrays - Primitive** - arrays of primitive values
- ✅ **Arrays - Tabular** - uniform arrays of objects
- ✅ **Arrays - Nested** - nested array structures
- ✅ **Delimiters** - comma, tab, and pipe delimiters
- ✅ **Whitespace** - whitespace handling in decoding
- ✅ **Root Form** - root-level array and object forms
- ✅ **Validation Errors** - length mismatches, invalid escapes, syntax errors
- ✅ **Indentation Errors** - strict mode indentation validation
- ✅ **Blank Lines** - handling of blank lines in TOON format

## Test Results

All tests from the TOON specification v1.4 pass successfully! ✅

The implementation correctly handles:
- String quoting and escaping
- Number formatting (including large integers)
- Object and array encoding/decoding
- Tabular array format
- Various delimiters
- Encoding options

## Test Fixtures

Test fixtures are downloaded from:
https://github.com/toon-format/spec/tree/main/tests/fixtures

These fixtures are language-agnostic and ensure consistency across all TOON implementations.

