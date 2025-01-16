type ast = node list [@@deriving show]

and node =
  | AExpr of aexpr
  | AStmt of astmt
  | Illegal
  | EOP
[@@deriving show]

and astmt =
  | ALet of aident * aexpr
  | AFunc of aident * paramaters * aexpr
[@@deriving show]

and paramater = aident [@@deriving show]
and paramaters = paramater list [@@deriving show]

and aexpr =
  | AValue of avalue
  | ACall of acall
  | ABinary of abinary
  | AMatch of amatch
  | ABlock of ablock
[@@deriving show]

and ablock = node list [@@deriving show]
and abinary = aexpr * aoperation * aexpr [@@deriving show]
and acall = aident * aexpr list [@@deriving show]
and amatch = (aexpr * aexpr) list [@@deriving show]

and aoperation =
  | AEq
  | AEqEq
  | ALess
  | ALessEq
  | AMore
  | AMoreEq
  | APlus
  | ASub
  | AMul
  | ADiv
[@@deriving show]

and aident = string [@@deriving show]

and avalue =
  | AInt of int
  | AFloat of float
  | AString of string
  | AIdent of aident
[@@deriving show]
