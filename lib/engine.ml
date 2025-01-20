(*TODO: Work on this stuff, I kinda want to see if I can just generate the code into simple lambda calculus, which should be possible I'm pretty sure, but lets see*)

module Term = struct
  type term =
    | Abstr of (string * term)
    | Apply of (term * term list)
    | Value of value

  and value =
    | Int of int
    | Float of float
    | String of string
    | Ident of string

  type terms = term list
end

type engine =
  { e : env
  ; t : Term.terms
  }

and env =
  { g : var list
  ; s : scope
  }

and var =
  { n : string
  ; v : Term.terms
  }

and scope = { p : scope option }
