# Implementation Notes

## Compilation Process

### Target Selection

We use `wasm32-wasip1` (previously called `wasm32-wasi`), the WebAssembly System Interface target. This provides:
- File system access through WASI APIs
- Standard I/O (stdin, stdout, stderr)
- Environment variables
- Command-line arguments

### Build Configuration

The default build works without modifications:

```bash
cargo build --release --target wasm32-wasip1
```

No features need to be disabled. Ripgrep has excellent WASI support built-in.

## Trade-offs and Design Decisions

### 1. No `--no-default-features` Required

Unlike some Rust projects, ripgrep compiles cleanly to WASI without disabling features. The crate handles platform differences internally.

### 2. Memory-Mapped Files

The native version uses `mmap` for fast file reading. The WASI version falls back to standard file I/O:
- Slightly slower for very large files
- No practical impact for typical search workloads
- More predictable memory usage

### 3. Parallelism

Native ripgrep uses parallel directory walking and file searching. The WASI version:
- Uses sequential processing (WASI doesn't support threading)
- Still fast due to efficient algorithms
- Suitable for most use cases

### 4. Binary Size

| Version | Size |
|---------|------|
| Native (arm64) | ~5 MB |
| WASM | ~19 MB |

The WASM binary is larger because:
- Includes Rust standard library compiled to WASM
- No dead code elimination across WASM boundaries
- Debug symbols included for better error messages

### 5. Startup Time

WASM has ~100-200ms startup overhead for JIT compilation. For single searches this is noticeable. For multiple searches, consider:
- Using a persistent runtime
- Pre-compiling the WASM module to native code

## Package Distribution Strategy

### NPM Package

- Binary downloaded from GitHub Releases during `postinstall`
- Falls back gracefully if release doesn't exist
- User can manually place binary

### Ruby Gem

- Binary downloaded on first `RipgrepWasm.path` call
- Lazy download avoids install-time network requirements
- Stored in gem's lib directory

## Runtime Requirements

### WasmTime Flags

```bash
wasmtime --dir=. rg.wasm ...
```

- `--dir=.`: Required for file system access (WASI sandbox)
- Additional directories can be mapped: `--dir=/path/to/search`

### Memory Limits

Default WasmTime memory is sufficient. For very large files, increase with:
```bash
wasmtime --max-memory-size=1073741824 --dir=. rg.wasm ...
```

## Known Issues

1. **Color output in piped mode**: May not work in all environments
2. **Symlink following**: Limited by WASI capabilities
3. **Git integration**: Cannot shell out to git for .gitignore parsing (uses internal implementation)

## Future Improvements

- Pre-compiled native modules for faster startup
- Component Model support when WASI stabilizes
- Streaming search API for Node.js/Ruby integration
