template Map[R, T, U] {
    proc map(range: R, mfn: (T) -> U) {
        for x in R {
            yield mfn(x)
        }
    }
}
