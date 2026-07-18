<div align="center">

# 🦉 owlsh

*A tiny, fast, customizable shell for Windows.*

[![Zig](https://img.shields.io/badge/Zig-0.16.0-f7a41d?logo=zig&logoColor=white)](https://ziglang.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-0078D6?logo=windows&logoColor=white)](#requirements)
[![Status](https://img.shields.io/badge/status-WIP-orange.svg)](#)

</div>

owlsh is a minimal, fast shell for Windows, built from scratch in Zig. It's designed to be highly customizable and snappy, giving you a shell that feels exactly the way you want it to.
> ⚠️ **Work in progress** — owlsh is under active development. Expect missing features, rough edges, and breaking changes.

## Roadmap

- [x] Read-Eval-Print Loop
- [x] Two-Line-Prompt (user@host + current directory, ~ for home)
- [x] UTF-8-console output for Windows
- [x] Quote-aware tokenizer
- [ ] Builtins:
    - [x] `exit`
    - [x] `cd`
    - [x] `clear`
    - [x] `pwd`
    - [x] `echo`
    - [ ] `export`
    - [ ] `set`, `unset`
    - [ ] `alias`, `unalias`
    - [ ] `history`
    - [ ] `source`
- [x] Extern program-execution
- [ ] Piping/Redirects
- [ ] .owlshrc-support (config-file)

## Requirements

- Zig 0.16.0
- Windows

## Build & Run

```sh
zig build
zig build run
```

Run the built binary directly:

```sh
zig-out\bin\owlsh.exe
```

## License

MIT — see [LICENSE](LICENSE).
