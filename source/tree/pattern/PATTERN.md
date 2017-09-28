# Pattern Matching #

Pattern matching is an extremely powerful concept, one that makes writing
software very expressive. The goal of the pattern matching subsystem in
the Aleph compiler is to unify very common processes within the optimizer, 
the semantic analyzer, the desugarer, and the generator.

In the future this package will most likely be released as its own package,
as I see great potential for usage within other D projects.

This library aims to be highly flexible. You can redefine how patterns are
parsed, and you can parse at compile time or runtime.

## String Pattern Grammar ##
using the `matcher` function, you can create patterns from strings.
`%` - match anything, ignoring it
`<id>` - match on variable
`"..."` - match on string
`<num>` - match on number value
`(...)` - match on aggregate type (struct, class, tuple)

### Examples ###

`match!"(x y 0)"` - match on aggregate data types that contain an x member, a y member, an a third member containing 0
