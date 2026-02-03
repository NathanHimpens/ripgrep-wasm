# ripgrep-wasm

Ripgrep 15.1.0 compiled to WebAssembly for fast text search in WASI environments.

## Overview

This project provides [ripgrep](https://github.com/BurntSushi/ripgrep) (rg), a blazingly fast search tool, compiled to WebAssembly. It can be executed with any WASI-compatible runtime like [WasmTime](https://wasmtime.dev/).

## Installation

### NPM

```bash
npm install @nathanhimpens/ripgrep-wasm
```

```javascript
const rgWasmPath = require('@nathanhimpens/ripgrep-wasm');
console.log(rgWasmPath); // Path to rg.wasm
```

### Ruby Gem

```bash
gem install ripgrep_wasm
```

```ruby
require 'ripgrep_wasm'
puts RipgrepWasm.path      # Path to rg.wasm
puts RipgrepWasm.available? # true if binary exists
```

### Manual

Download `rg.wasm` from [GitHub Releases](https://github.com/NathanHimpens/ripgrep-wasm/releases).

## Usage with WasmTime

The `--dir=.` flag is required to grant file system access (WASI sandbox):

```bash
# Search for "pattern" in a file
wasmtime --dir=. rg.wasm "pattern" file.txt

# Search recursively in current directory
wasmtime --dir=. rg.wasm "TODO" .

# Case-insensitive search
wasmtime --dir=. rg.wasm -i "error" logs/

# Show line numbers
wasmtime --dir=. rg.wasm -n "function" src/

# Search with context (2 lines before/after)
wasmtime --dir=. rg.wasm -C 2 "bug" .
```

## Building from Source

### Prerequisites

- Rust with rustup
- WasmTime CLI (for testing)

### Build Steps

```bash
# Install WASI target
rustup target add wasm32-wasip1

# Clone ripgrep
git clone --depth 1 https://github.com/BurntSushi/ripgrep.git
cd ripgrep

# Build for WASM
cargo build --release --target wasm32-wasip1

# Binary location
ls -la target/wasm32-wasip1/release/rg.wasm
```

### Test the Build

```bash
echo "Hello World\nTest pattern\nAnother line" > test.txt
wasmtime --dir=. ./target/wasm32-wasip1/release/rg.wasm "pattern" test.txt
# Output: Test pattern
```

## Features

The WASM build includes:
- Full regex support
- Unicode support
- Color output (when terminal supports it)
- .gitignore respect
- Multiple file type filters
- Context lines (-A, -B, -C)
- Line numbers (-n)
- Case insensitive search (-i)
- Inverted matching (-v)
- Count matches (-c)
- JSON output (--json)

## Limitations

Compared to native ripgrep:
- **No memory-mapped files**: All file I/O is through standard read/write
- **Single-threaded**: WASI doesn't support threading (uses fallback sequential implementation)
- **No process spawning**: Cannot use external commands like git for .gitignore
- **Larger binary size**: ~19MB vs ~5MB native (includes Rust runtime for WASM)

## License

- This wrapper: MIT
- Ripgrep: MIT/Unlicense (dual-licensed)

## Links

- [ripgrep repository](https://github.com/BurntSushi/ripgrep)
- [WasmTime](https://wasmtime.dev/)
- [WASI specification](https://wasi.dev/)
