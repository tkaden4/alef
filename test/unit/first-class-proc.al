proc apply_fn(a: int, b: int, fn: (int, int) -> int) -> int = {
    fn(a, b);
};

proc add(a: int, b: int) -> int = a + b;

proc main() -> int = apply_fn(0, 0, add);
