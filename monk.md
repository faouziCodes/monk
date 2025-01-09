# Lambda Calculus

## Bound variables

- Lets  say I write the following:

```rust
// Identity function applied to "true"
((\x.x) "true")
(\true.true)
true

// How could we turn it into this:
((\1.1) "true")
```
I geuss I want to go from named bound variables, to de bruijn indices.
Where the numbers denote how far it is from their bounder.



## Church numerals

C0 = \f.\x. x
C1 = \f.\x. f(x)
C2 = \f.\x. f(f(x))

We could then go ahead and perhaps add 1 and ehm zero.


# Compilers v Interpreters (Speed)

Consider this:

```rust
let add = (x, y): int -> int -> int => {
  x + y
}

let x = add(10, 20)
```

Consider a compiler who turns it into, (imagine assembly tho)

```rust
add(x, y):
  push x
  push y
  add, r0, r1

store(add(10, 20), r0)
```

And then a interpreter who does the following, not because it inlined simply because it rewrites.

```rust
let x = 30
```

(1, 1) : (int, int)

idk tho


# The frontend of the language

## Important before we start writing the language:

- Type of language:

  - Functional

  - I don't want people to be able to change the language to their liking, it's the same everywhere:

    - So I don't want this:
      ```rust
        #define  = as is
        (x is 10)
      ```

    - Or this:
      ```rust
        #define  is as '='
        (x = 10)
      ```

  - I do want a mix of keywords and symbols, or perhaps define them as functions, and have a type for operations/symbols.


## Consider this (about symbols)

- Type is a function of the language

- It is only a function before we perform any type checking, this means that we will need some form of build-ins that get run before any of the compiler part
gets run.

Consider some kind of Env like this:

```rust
type(env{
  symbols
})
```

```rust
symbols(lhs, ->, rhs do rhs)

symbols(lhs, :=, rhs -> lhs(rhs))

symbols := lhs, :=, rhs ->
```

Hmm, no don't like it, to complex.

Perhaps we don't go with the build-in functions way, and just have keywords?

```
match x with y

if then else
```

But then how would we easily add symbols to our language?

- Why do I even want to have the ability to add symbols to my programming language:

- really I want the syntax of the language to never change, not even if we add new functionalitty.

  - I should be able to build the most complex feature of the language on the simplest parts.
  To me a simple part of the language is the symbols, they are fast to type and once you know the meaning it becomes even easier to understand what you're doing.;


Ehm, I don't know just how to do this yet.

( ( value, ><, (m, l) ) : lhs = rhs )  :: Symbols

Perhaps  we just don't do it

## Keeping it simple:

If one want's to define a variable, why exactly do we need a keyword for that:

```rust
let x = 10
```

What if instead of needing let to detect if a variable is getting created we just use the '='?

```rust
x := 10
```

Functions:

```rust
add := lhs, rhs  -> {
  lhs + rhs
}

(10, 20)
(10., 20.)
add(10., 20.)
```

Patternmatching:

```rust
iter :=
  cb, [] -> ()
  | cb, head :: rest ->  {
      cb(head)
      (cb, rest)
  }


show_list_item := item -> {
  print(item)
}

(show_list_item, [1, 2, 3, 4])
iter (show_list_item, [1, 2, 3, 4])
#eval("io", iter(show_list_item, [1, 2, 3, 4])) // 1 2 3 4
```

If else

```rust
wow :=
  (1, 10) -> {
    print(1)
  }
  // oh oh:
  | _  -> {
    print(10)
  }

#eval("io", ((1; 10))) // 1
#eval("io", ((10; 1))) // 10
```

Types

```rust
point := { x : int; y : int; }
point := { x = 0; y = 0 }
```

Variables

```rust
x = 10
```

# Linking a call to the function without a name

How can I implement correctly and easily a way in which a user can do the following:

```rust
add := (a, b) -> a + b
(10, 20)
```

And produce the following

```rust
add := (a, b) -> a + b
(10, 20)
```

If we really think about it (using hindley milner):

```rust
(10, 20) :  int -> int
```

And the function:

```rust
add : int -> int -> int
```


1. What if we keep the return type out of the scheme of the function:
  - So if we get add : int -> int -> int
    We treat the first part: int -> int, as a "expected params type" and the last part as its return type.

I geuss we can do it that way.

# Difference

```rust
A: point := { x : int; y : int; }
B: point := { x = 0; y = 0 }
```

In the above code what is the difference between A and B.
It's obvious in the syntax, but in ctx of the compiler why are the two different.
