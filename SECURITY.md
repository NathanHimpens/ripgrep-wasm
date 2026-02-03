# Security Considerations

## WASI Sandbox

The WASM binary runs in a sandboxed environment. By default, it has **no access** to the file system. Access must be explicitly granted:

```bash
# Grant access to current directory only
wasmtime --dir=. rg.wasm "pattern" .

# Grant access to specific directory
wasmtime --dir=/path/to/search rg.wasm "pattern" /path/to/search
```

### What the Binary CAN Do

With `--dir` access granted:
- Read files in the specified directory tree
- Write to stdout/stderr
- Read environment variables
- Process command-line arguments

### What the Binary CANNOT Do

Even with file system access:
- Execute other programs
- Access network
- Access files outside granted directories
- Modify system settings
- Access hardware directly

## Supply Chain Security

### Binary Provenance

The `rg.wasm` binary is:
1. Built from official ripgrep source code
2. Compiled with standard Rust toolchain
3. No modifications to ripgrep source

### Verification

To verify the binary matches the source:

```bash
# Clone and build yourself
git clone --depth 1 https://github.com/BurntSushi/ripgrep.git
cd ripgrep
rustup target add wasm32-wasip1
cargo build --release --target wasm32-wasip1

# Compare checksums
sha256sum target/wasm32-wasip1/release/rg.wasm
sha256sum /path/to/downloaded/rg.wasm
```

Note: Checksums may differ slightly due to build environment, but functionality is identical.

## Package Security

### NPM Package

- No runtime dependencies
- Downloads binary over HTTPS from GitHub
- Verifies GitHub API responses
- Falls back gracefully on network errors

### Ruby Gem

- No external gem dependencies
- Downloads binary over HTTPS from GitHub
- Uses Ruby standard library only

## Reporting Vulnerabilities

For security issues in:
- **This wrapper**: Open a GitHub issue or contact the maintainer
- **Ripgrep itself**: Report to [ripgrep security](https://github.com/BurntSushi/ripgrep/security)
- **WasmTime**: Report to [WasmTime security](https://github.com/bytecodealliance/wasmtime/security)

## Best Practices

1. **Minimize directory access**: Only grant `--dir` to directories that need searching
2. **Verify binary integrity**: Check checksums for downloaded binaries
3. **Keep updated**: Update packages regularly for security fixes
4. **Isolate execution**: Run in containers or VMs for untrusted searches
