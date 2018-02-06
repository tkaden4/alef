# Alef #

Alef is a modern, clean replacement for the C programming language
inspired by [C2](http://c2lang.org/), Rust, and OCaml.

Alef is a *work in progress*, and breaking changes will made frequently.

See SPEC.md for the specification

### Improvements over C (Work in progress)
- CTFE (Compile-time function execution)
- REPL for rapid prototyping and testing
- Strong typing
- Module system

### Goals
- Higher Kinded Types
- Closures
- Type inference
- Traits
- LLVM/RTL Targets
- Integrated C compiler

### Usage
launch REPL

`alefc --repl`

compile files

`alefc -o main main.al ...`
