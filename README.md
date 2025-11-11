# Token-Oriented Object Notation (TOON) for Dart

[![pub package](https://img.shields.io/pub/v/toon_format.svg)](https://pub.dev/packages/toon_x_json)
[![pub points](https://img.shields.io/pub/points/toon_format.svg)](https://pub.dev/packages/toon_x_json/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

**Token-Oriented Object Notation** is a compact, human-readable serialization format designed for passing structured data to Large Language Models with significantly reduced token usage. It's intended for *LLM input* as a lossless, drop-in representation of JSON data.

TOON's sweet spot is **uniform arrays of objects** – multiple fields per row, same structure across items. It borrows YAML's indentation-based structure for nested objects and CSV's tabular format for uniform data rows, then optimizes both for token efficiency in LLM contexts. For deeply nested or non-uniform data, JSON may be more efficient.

TOON achieves CSV-like compactness while adding explicit structure that helps LLMs parse and validate data reliably.

> [!TIP]
> Think of TOON as a translation layer: use JSON programmatically, convert to TOON for LLM input.

## Table of Contents

- [Why TOON?](#why-toon)
- [Key Features](#key-features)
- [Benchmarks](#benchmarks)
- [📋 Full Specification](https://github.com/toon-format/spec/blob/main/SPEC.md)
- [Installation & Quick Start](#installation--quick-start)
- [Format Overview](#format-overview)
- [API](#api)
- [Using TOON in LLM Prompts](#using-toon-in-llm-prompts)
- [Notes and Limitations](#notes-and-limitations)
- [Syntax Cheatsheet](#syntax-cheatsheet)
- [Examples](#examples)
- [Other Implementations](#other-implementations)

## Why TOON?

AI is becoming cheaper and more accessible, but larger context windows allow for larger data inputs as well. **LLM tokens still cost money** – and standard JSON is verbose and token-expensive:

```json
{
  "users": [
    { "id": 1, "name": "Alice", "role": "admin" },
    { "id": 2, "name": "Bob", "role": "user" }
  ]
}
```

TOON conveys the same information with **fewer tokens**:

```
users[2]{id,name,role}:
  1,Alice,admin
  2,Bob,user
```

<details>
<summary><strong>Why create a new format?</strong></summary>

For small payloads, JSON/CSV/YAML work fine. TOON's value emerges at scale: when you're making hundreds of LLM calls with uniform tabular data, eliminating repeated keys compounds savings significantly. If token costs matter to your use case, TOON reduces them. If not, stick with what works.

</details>

<details>
<summary><strong>When NOT to use TOON</strong></summary>

TOON excels with uniform arrays of objects, but there are cases where other formats are better:

- **Deeply nested or non-uniform structures** (tabular eligibility ≈ 0%): JSON-compact often uses fewer tokens. Example: complex configuration objects with many nested levels.
- **Semi-uniform arrays** (~40–60% tabular eligibility): Token savings diminish. Prefer JSON if your pipelines already rely on it.
- **Flat CSV use-cases**: CSV is smaller than TOON for pure tabular data. TOON adds minimal overhead (~5-10%) to provide structure (length markers, field headers, delimiter scoping) that improves LLM reliability.

See [benchmarks](#benchmarks) for concrete comparisons across different data structures.

</details>

## Key Features

- 💸 **Token-efficient:** typically 30-60% fewer tokens on large uniform arrays vs formatted JSON[^1]
- 🤿 **LLM-friendly guardrails:** explicit lengths and fields enable validation
- 🍱 **Minimal syntax:** removes redundant punctuation (braces, brackets, most quotes)
- 📐 **Indentation-based structure:** like YAML, uses whitespace instead of braces
- 🧺 **Tabular arrays:** declare keys once, stream data as rows

[^1]: For flat tabular data, CSV is more compact. TOON adds minimal overhead to provide explicit structure and validation that improves LLM reliability.

## Benchmarks

> [!TIP]
> Try the interactive [Format Tokenization Playground](https://www.curiouslychase.com/playground/format-tokenization-exploration) to compare token usage across CSV, JSON, YAML, and TOON with your own data.

Benchmarks are organized into two tracks to ensure fair comparisons:

- **Mixed-Structure Track**: Datasets with nested or semi-uniform structures (TOON vs JSON, YAML, XML). CSV excluded as it cannot properly represent these structures.
- **Flat-Only Track**: Datasets with flat tabular structures where CSV is applicable (CSV vs TOON vs JSON, YAML, XML).

### Token Efficiency

Token counts are measured using the GPT-5 `o200k_base` tokenizer via [`gpt-tokenizer`](https://github.com/niieani/gpt-tokenizer). Savings are calculated against formatted JSON (2-space indentation) as the primary baseline, with additional comparisons to compact JSON (minified), YAML, and XML. Actual savings vary by model and tokenizer.

The benchmarks test datasets across different structural patterns (uniform, semi-uniform, nested, deeply nested) to show where TOON excels and where other formats may be better.

#### Mixed-Structure Track

Datasets with nested or semi-uniform structures. CSV excluded as it cannot properly represent these structures.

```
🛒 E-commerce orders with nested structures  ┊  Tabular: 33%
   │
   TOON                █████████████░░░░░░░    72,771 tokens
   ├─ vs JSON          (−33.1%)               108,806 tokens
   ├─ vs JSON compact  (+5.5%)                 68,975 tokens
   ├─ vs YAML          (−14.2%)                84,780 tokens
   └─ vs XML           (−40.5%)               122,406 tokens

🧾 Semi-uniform event logs  ┊  Tabular: 50%
   │
   TOON                █████████████████░░░   153,211 tokens
   ├─ vs JSON          (−15.0%)               180,176 tokens
   ├─ vs JSON compact  (+19.9%)               127,731 tokens
   ├─ vs YAML          (−0.8%)                154,505 tokens
   └─ vs XML           (−25.2%)               204,777 tokens

🧩 Deeply nested configuration  ┊  Tabular: 0%
   │
   TOON                ██████████████░░░░░░       631 tokens
   ├─ vs JSON          (−31.3%)                   919 tokens
   ├─ vs JSON compact  (+11.9%)                   564 tokens
   ├─ vs YAML          (−6.2%)                    673 tokens
   └─ vs XML           (−37.4%)                 1,008 tokens

──────────────────────────────────── Total ────────────────────────────────────
   TOON                ████████████████░░░░   226,613 tokens
   ├─ vs JSON          (−21.8%)               289,901 tokens
   ├─ vs JSON compact  (+14.9%)               197,270 tokens
   ├─ vs YAML          (−5.6%)                239,958 tokens
   └─ vs XML           (−31.0%)               328,191 tokens
```

#### Flat-Only Track

Datasets with flat tabular structures where CSV is applicable.

```
👥 Uniform employee records  ┊  Tabular: 100%
   │
   CSV                 ███████████████████░    46,954 tokens
   TOON                ████████████████████    49,831 tokens   (+6.1% vs CSV)
   ├─ vs JSON          (−60.7%)               126,860 tokens
   ├─ vs JSON compact  (−36.8%)                78,856 tokens
   ├─ vs YAML          (−50.0%)                99,706 tokens
   └─ vs XML           (−66.0%)               146,444 tokens

📈 Time-series analytics data  ┊  Tabular: 100%
   │
   CSV                 ██████████████████░░     8,388 tokens
   TOON                ████████████████████     9,120 tokens   (+8.7% vs CSV)
   ├─ vs JSON          (−59.0%)                22,250 tokens
   ├─ vs JSON compact  (−35.8%)                14,216 tokens
   ├─ vs YAML          (−48.9%)                17,863 tokens
   └─ vs XML           (−65.7%)                26,621 tokens

⭐ Top 100 GitHub repositories  ┊  Tabular: 100%
   │
   CSV                 ███████████████████░     8,513 tokens
   TOON                ████████████████████     8,745 tokens   (+2.7% vs CSV)
   ├─ vs JSON          (−42.3%)                15,145 tokens
   ├─ vs JSON compact  (−23.7%)                11,455 tokens
   ├─ vs YAML          (−33.4%)                13,129 tokens
   └─ vs XML           (−48.8%)                17,095 tokens

──────────────────────────────────── Total ────────────────────────────────────
   CSV                 ███████████████████░    63,855 tokens
   TOON                ████████████████████    67,696 tokens   (+6.0% vs CSV)
   ├─ vs JSON          (−58.8%)               164,255 tokens
   ├─ vs JSON compact  (−35.2%)               104,527 tokens
   ├─ vs YAML          (−48.2%)               130,698 tokens
   └─ vs XML           (−64.4%)               190,160 tokens
```

### Retrieval Accuracy

Benchmarks test LLM comprehension across different input formats using 209 data retrieval questions on 4 models.

#### Efficiency Ranking (Accuracy per 1K Tokens)

Each format's overall performance, balancing accuracy against token cost:

```
TOON           ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   26.9  │  73.9% acc  │  2,744 tokens
JSON compact   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░   22.9  │  70.7% acc  │  3,081 tokens
YAML           ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░   18.6  │  69.0% acc  │  3,719 tokens
JSON           ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░   15.3  │  69.7% acc  │  4,545 tokens
XML            ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░   13.0  │  67.1% acc  │  5,167 tokens
```

TOON achieves **73.9%** accuracy (vs JSON's 69.7%) while using **39.6% fewer tokens**.

## Installation & Quick Start

Add `toon_x_json` to your `pubspec.yaml`:

```yaml
dependencies:
  toon_x_json: ^0.0.3
```

Then run:

```bash
dart pub get
# or
flutter pub get
```

**Example usage:**

```dart
import 'package:toon_x_json/toon_x_json.dart';

void main() {
  final data = {
    'users': [
      {'id': 1, 'name': 'Alice', 'role': 'admin'},
      {'id': 2, 'name': 'Bob', 'role': 'user'}
    ]
  };

  final toon = encode(data);
  print(toon);
  // users[2]{id,name,role}:
  //   1,Alice,admin
  //   2,Bob,user
}
```

## Format Overview

> [!NOTE]
> For precise formatting rules and implementation details, see the [full specification](https://github.com/toon-format/spec).

### Objects

Simple objects with primitive values:

```dart
encode({
  'id': 123,
  'name': 'Ada',
  'active': true
})
```

```
id: 123
name: Ada
active: true
```

Nested objects:

```dart
encode({
  'user': {
    'id': 123,
    'name': 'Ada'
  }
})
```

```
user:
  id: 123
  name: Ada
```

### Arrays

> [!TIP]
> TOON includes the array length in brackets (e.g., `items[3]`). When using comma delimiters (default), the delimiter is implicit. When using tab or pipe delimiters, the delimiter is explicitly shown in the header (e.g., `tags[2|]` or `[2	]`). This encoding helps LLMs identify the delimiter and track the number of elements, reducing errors when generating or validating structured output.

#### Primitive Arrays (Inline)

```dart
encode({
  'tags': ['admin', 'ops', 'dev']
})
```

```
tags[3]: admin,ops,dev
```

#### Arrays of Objects (Tabular)

When all objects share the same primitive fields, TOON uses an efficient **tabular format**:

```dart
encode({
  'items': [
    {'sku': 'A1', 'qty': 2, 'price': 9.99},
    {'sku': 'B2', 'qty': 1, 'price': 14.5}
  ]
})
```

```
items[2]{sku,qty,price}:
  A1,2,9.99
  B2,1,14.5
```

**Tabular formatting applies recursively:** nested arrays of objects (whether as object properties or inside list items) also use tabular format if they meet the same requirements.

> [!NOTE]
> Tabular format requires identical field sets across all objects (same keys, order doesn't matter) and primitive values only (strings, numbers, booleans, null).

#### Mixed and Non-Uniform Arrays

Arrays that don't meet the tabular requirements use list format:

```
items[3]:
  - 1
  - a: 1
  - text
```

When objects appear in list format, the first field is placed on the hyphen line:

```
items[2]:
  - id: 1
    name: First
  - id: 2
    name: Second
    extra: true
```

#### Arrays of Arrays

When you have arrays containing primitive inner arrays:

```dart
encode({
  'pairs': [
    [1, 2],
    [3, 4]
  ]
})
```

```
pairs[2]:
  - [2]: 1,2
  - [2]: 3,4
```

#### Empty Arrays and Objects

Empty containers have special representations:

```dart
encode({'items': []}) // items[0]:
encode([]) // [0]:
encode({}) // (empty output)
encode({'config': {}}) // config:
```

### Quoting Rules

TOON quotes strings **only when necessary** to maximize token efficiency:

- Inner spaces are allowed; leading or trailing spaces force quotes.
- Unicode and emoji are safe unquoted.
- Quotes and control characters are escaped with backslash.

> [!NOTE]
> When using alternative delimiters (tab or pipe), the quoting rules adapt automatically. Strings containing the active delimiter will be quoted, while other delimiters remain safe.

#### Object Keys and Field Names

Keys are unquoted if they match the identifier pattern: start with a letter or underscore, followed by letters, digits, underscores, or dots (e.g., `id`, `userName`, `user_name`, `user.name`, `_private`). All other keys must be quoted (e.g., `"user name"`, `"order-id"`, `"123"`, `"order:id"`, `""`).

#### String Values

String values are quoted when any of the following is true:

| Condition | Examples |
|---|---|
| Empty string | `""` |
| Leading or trailing spaces | `" padded "`, `"  "` |
| Contains active delimiter, colon, quote, backslash, or control chars | `"a,b"` (comma), `"a\tb"` (tab), `"a\|b"` (pipe), `"a:b"`, `"say \"hi\""`, `"C:\\Users"`, `"line1\\nline2"` |
| Looks like boolean/number/null | `"true"`, `"false"`, `"null"`, `"42"`, `"-3.14"`, `"1e-6"`, `"05"` |
| Starts with `"- "` (list-like) | `"- item"` |
| Looks like structural token | `"[5]"`, `"{key}"`, `"[3]: x,y"` |

**Examples of unquoted strings:** Unicode and emoji are safe (`hello 👋 world`), as are strings with inner spaces (`hello world`).

> [!IMPORTANT]
> **Delimiter-aware quoting:** Unquoted strings never contain `:` or the active delimiter. This makes TOON reliably parseable with simple heuristics: split key/value on first `: `, and split array values on the delimiter declared in the array header. When using tab or pipe delimiters, commas don't need quoting – only the active delimiter triggers quoting for both array values and object values.

### Type Conversions

Some non-JSON types are automatically normalized for LLM-safe output:

| Input | Output |
|---|---|
| Number (finite) | Decimal form, no scientific notation (e.g., `-0` → `0`, `1e6` → `1000000`) |
| Number (`NaN`, `±Infinity`) | `null` |
| `BigInt` | If within safe integer range: converted to number. Otherwise: quoted decimal string (e.g., `"9007199254740993"`) |
| `DateTime` | ISO string in quotes (e.g., `"2025-01-01T00:00:00.000Z"`) |
| `Map` | Converted to object |
| `Set` | Converted to array |
| `List` | Converted to array |

## API

### `encode(value: Object?, {EncodeOptions? options}): String`

Converts any JSON-serializable value to TOON format.

**Parameters:**

- `value` – Any JSON-serializable value (Map, List, primitive, or nested structure). Non-JSON-serializable values are converted to `null`. Dates are converted to ISO strings, and BigInts are emitted as decimal integers (no quotes).
- `options` – Optional encoding options:
  - `indent` – Number of spaces per indentation level (default: `2`)
  - `delimiter` – Delimiter for array values and tabular rows: `','` (comma), `'\t'` (tab), `'|'` (pipe) (default: `','`)
  - `lengthMarker` – Optional marker to prefix array lengths: `'#'` or `null` (default: `null`)

**Returns:**

A TOON-formatted string with no trailing newline or spaces.

**Example:**

```dart
import 'package:toon_x_json/toon_x_json.dart';

final items = [
  {'sku': 'A1', 'qty': 2, 'price': 9.99},
  {'sku': 'B2', 'qty': 1, 'price': 14.5}
];

encode({'items': items})
```

**Output:**

```
items[2]{sku,qty,price}:
  A1,2,9.99
  B2,1,14.5
```

#### Delimiter Options

The `delimiter` option allows you to choose between comma (default), tab, or pipe delimiters for array values and tabular rows. Alternative delimiters can provide additional token savings in specific contexts.

##### Tab Delimiter (`\t`)

Using tab delimiters instead of commas can reduce token count further, especially for tabular data:

```dart
final data = {
  'items': [
    {'sku': 'A1', 'name': 'Widget', 'qty': 2, 'price': 9.99},
    {'sku': 'B2', 'name': 'Gadget', 'qty': 1, 'price': 14.5}
  ]
};

encode(data, options: EncodeOptions(delimiter: '\t'));
```

**Output:**

```
items[2	]{sku	name	qty	price}:
  A1	Widget	2	9.99
  B2	Gadget	1	14.5
```

**Benefits:**

- Tabs are single characters and often tokenize more efficiently than commas.
- Tabs rarely appear in natural text, reducing the need for quote-escaping.
- The delimiter is explicitly encoded in the array header, making it self-descriptive.

**Considerations:**

- Some terminals and editors may collapse or expand tabs visually.
- String values containing tabs will still require quoting.

##### Pipe Delimiter (`|`)

Pipe delimiters offer a middle ground between commas and tabs:

```dart
encode(data, options: EncodeOptions(delimiter: '|'));
```

**Output:**

```
items[2|]{sku|name|qty|price}:
  A1|Widget|2|9.99
  B2|Gadget|1|14.5
```

#### Length Marker Option

The `lengthMarker` option adds an optional hash (`#`) prefix to array lengths to emphasize that the bracketed value represents a count, not an index:

```dart
final data = {
  'tags': ['reading', 'gaming', 'coding'],
  'items': [
    {'sku': 'A1', 'qty': 2, 'price': 9.99},
    {'sku': 'B2', 'qty': 1, 'price': 14.5},
  ],
};

encode(data, options: EncodeOptions(lengthMarker: '#'));
// tags[#3]: reading,gaming,coding
// items[#2]{sku,qty,price}:
//   A1,2,9.99
//   B2,1,14.5

// Custom delimiter with length marker
encode(data, options: EncodeOptions(
  lengthMarker: '#',
  delimiter: '|',
));
// tags[#3|]: reading|gaming|coding
// items[#2|]{sku|qty|price}:
//   A1|2|9.99
//   B2|1|14.5
```

### `decode(input: String, {DecodeOptions? options}): Object?`

Converts a TOON-formatted string back to Dart values.

**Parameters:**

- `input` – A TOON-formatted string to parse
- `options` – Optional decoding options:
  - `indent` – Expected number of spaces per indentation level (default: `2`)
  - `strict` – Enable strict validation (default: `true`)

**Returns:**

A Dart value (Map, List, or primitive) representing the parsed TOON data.

**Example:**

```dart
import 'package:toon_x_json/toon_x_json.dart';

const toon = '''
items[2]{sku,qty,price}:
  A1,2,9.99
  B2,1,14.5
''';

final data = decode(toon);
// {
//   'items': [
//     {'sku': 'A1', 'qty': 2, 'price': 9.99},
//     {'sku': 'B2', 'qty': 1, 'price': 14.5}
//   ]
// }
```

**Strict Mode:**

By default, the decoder validates input strictly:

- **Invalid escape sequences**: Throws on `"\x"`, unterminated strings.
- **Syntax errors**: Throws on missing colons, malformed headers.
- **Array length mismatches**: Throws when declared length doesn't match actual count.
- **Delimiter mismatches**: Throws when row delimiters don't match header.

## Notes and Limitations

- Format familiarity and structure matter as much as token count. TOON's tabular format requires arrays of objects with identical keys and primitive values only. When this doesn't hold (due to mixed types, non-uniform objects, or nested structures), TOON switches to list format where JSON can be more efficient at scale.
  - **TOON excels at:** Uniform arrays of objects (same fields, primitive values), especially large datasets with consistent structure.
  - **JSON is better for:** Non-uniform data, deeply nested structures, and objects with varying field sets.
  - **CSV is more compact for:** Flat, uniform tables without nesting. TOON adds structure (`[N]` length markers, delimiter scoping, deterministic quoting) that improves LLM reliability with minimal token overhead.
- **Token counts vary by tokenizer and model.** Benchmarks use a GPT-style tokenizer (cl100k/o200k); actual savings will differ with other models (e.g., SentencePiece).
- **TOON is designed for LLM input** where human readability and token efficiency matter. It's **not** a drop-in replacement for JSON in APIs or storage.

## Using TOON in LLM Prompts

TOON works best when you show the format instead of describing it. The structure is self-documenting – models parse it naturally once they see the pattern.

### Sending TOON to LLMs (Input)

Wrap your encoded data in a fenced code block (label it \`\`\`toon for clarity). The indentation and headers are usually enough – models treat it like familiar YAML or CSV. The explicit length markers (`[N]`) and field headers (`{field1,field2}`) help the model track structure, especially for large tables.

### Generating TOON from LLMs (Output)

For output, be more explicit. When you want the model to **generate** TOON:

- **Show the expected header** (`users[N]{id,name,role}:`). The model fills rows instead of repeating keys, reducing generation errors.
- **State the rules:** 2-space indent, no trailing spaces, `[N]` matches row count.

Here's a prompt that works for both reading and generating:

````
Data is in TOON format (2-space indent, arrays show length and fields).

```toon
users[3]{id,name,role,lastLogin}:
  1,Alice,admin,2025-01-15T10:30:00Z
  2,Bob,user,2025-01-14T15:22:00Z
  3,Charlie,user,2025-01-13T09:45:00Z
```

Task: Return only users with role "user" as TOON. Use the same header. Set [N] to match the row count. Output only the code block.
````

> [!TIP]
> For large uniform tables, use `encode(data, options: EncodeOptions(delimiter: '\t'))` and tell the model "fields are tab-separated." Tabs often tokenize better than commas and reduce the need for quote-escaping.

## Syntax Cheatsheet

<details>
<summary><strong>Show format examples</strong></summary>

```
// Object
{ id: 1, name: 'Ada' }          → id: 1
                                  name: Ada

// Nested object
{ user: { id: 1 } }             → user:
                                    id: 1

// Primitive array (inline)
{ tags: ['foo', 'bar'] }        → tags[2]: foo,bar

// Tabular array (uniform objects)
{ items: [                      → items[2]{id,qty}:
  { id: 1, qty: 5 },                1,5
  { id: 2, qty: 3 }                 2,3
]}

// Mixed / non-uniform (list)
{ items: [1, { a: 1 }, 'x'] }   → items[3]:
                                    - 1
                                    - a: 1
                                    - x

// Array of arrays
{ pairs: [[1, 2], [3, 4]] }     → pairs[2]:
                                    - [2]: 1,2
                                    - [2]: 3,4

// Root array
['x', 'y']                      → [2]: x,y

// Empty containers
{}                              → (empty output)
{ items: [] }                   → items[0]:

// Special quoting
{ note: 'hello, world' }        → note: "hello, world"
{ items: ['true', true] }       → items[2]: "true",true
```

</details>

## Examples

Check out the [examples directory](./example/) for comprehensive examples demonstrating:

- Simple JSON encoding/decoding
- Flat lists with different data types
- Nested structures
- Tabular arrays (best use case)
- Mixed arrays
- Custom encoding options
- Edge cases

Run examples with:

```bash
fvm dart run example/example.dart
fvm dart run example/1_simple_json.dart
# ... see example/README.md for all examples
```

## Other Implementations

> [!NOTE]
> When implementing TOON in other languages, please follow the [specification](https://github.com/toon-format/spec/blob/main/SPEC.md) (currently v1.4) to ensure compatibility across implementations. The [conformance tests](https://github.com/toon-format/spec/tree/main/tests) provide language-agnostic test fixtures that validate implementations across any language.

### Official Implementations

- **TypeScript/JavaScript:** [@toon-format/toon](https://github.com/toon-format/toon) (reference implementation)
- **Dart/Flutter:** [toon_x_json](https://github.com/Tushargupta9800/toon-dart) (this package) ⭐
- **Python:** [toon_format](https://github.com/toon-format/toon-python) *(in development)*
- **Rust:** [toon_format](https://github.com/toon-format/toon-rust) *(in development)*

### Community Implementations

- **.NET:** [ToonSharp](https://github.com/0xZunia/ToonSharp)
- **C++:** [ctoon](https://github.com/mohammadraziei/ctoon)
- **Clojure:** [toon](https://github.com/vadelabs/toon)
- **Crystal:** [toon-crystal](https://github.com/mamantoha/toon-crystal)
- **Elixir:** [toon_ex](https://github.com/kentaro/toon_ex)
- **Gleam:** [toon_codec](https://github.com/axelbellec/toon_codec)
- **Go:** [gotoon](https://github.com/alpkeskin/gotoon)
- **Java:** [JToon](https://github.com/felipestanzani/JToon)
- **Lua/Neovim:** [toon.nvim](https://github.com/thalesgelinger/toon.nvim)
- **OCaml:** [ocaml-toon](https://github.com/davesnx/ocaml-toon)
- **PHP:** [toon-php](https://github.com/HelgeSverre/toon-php)
- **R**: [toon](https://github.com/laresbernardo/toon)
- **Ruby:** [toon-ruby](https://github.com/andrepcg/toon-ruby)
- **Swift:** [TOONEncoder](https://github.com/mattt/TOONEncoder)

## Contributors
- **[Tushar Gupta](https://github.com/Tushargupta9800)**

## License

[MIT](./LICENSE) License © 2025-PRESENT [Johann Schopplich](https://github.com/johannschopplich)
