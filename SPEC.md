# Specification

// TODO incorporate memory management

## Types
### Primitive Types
`iN` - integers in the N bit range

`uN` - unsigned integers in the N bit range

`fN` - floating point numbers in the N bit range

### Compound Types
`(A, B)` - tuples, or the product of two types A and B

`[A]` - lists, or sequentially ordered collections of values

`{ foo of A, bar of B ... }` - records, or groups of named fields of different types

### Disjoint Types
`A | B | ...` - a type that is one of many disparate types

### Type Declaration
`type n = A` - create a new type of name n and specifier A

`alias n = B` - create an alias, effectively replacing usages of n with B

## Bindings
### Global Bindings
```
// x and bar are now exported at the top level
let x of i32 = 7
let bar (x of i32) (y of i32) of i32 = x + y
```
### Local Bindings
```
// print and x are not available after "print x"
let print (n of int32) of unit = std.io.println (std.int.to_string n) in
let x of i32 = 8 in
  print x
```

### Immutability
By default, all bindings in Alef are immutable
```
let x of i32 = 8 in
  x := 8    // error: binding "x" is not mutable

// by using ! with the type, we mark it as mutable
let y of !i32 = 8 in
  y := 8 ;  // all OK
  y := 9 ;  // also OK
  y
```

## Modules
```
// john.al
module John

let name of \*u8 = "John"
let age of i32 = 32

// foo.al
mod Foo

// access the "print" function in std.io and the "name" binding in John
std.io.println John.name
```

### Importing/Qualification
Symbols can be fully qualified, or imported

```
// print "0" to the string
std.io.println (std.int.to\_string 0)

// or

use std.int.{to\_string}
use std.io.{println}

to\_string 0 |> println

```

### Access Specifiers 
All symbols are private to the module by default

`export` - export the symbol from the module
