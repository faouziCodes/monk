type ast = node list
and node = AExpr of aexpr | AStmt of astmt | Illegal | EOP
and astmt = ALet of aident * aexpr | AFunc of aident * paramaters * astmt
and paramater = aident
and paramaters = paramater list

and aexpr =
  | AValue of avalue
  | ACall of acall
  | ABinary of abinary
  | AMatch of amatch
  | ABlock of ablock

and ablock = astmt list
and abinary = aexpr * aoperation * aexpr
and acall = aident * aexpr list
and amatch = (aexpr * aexpr) list

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

and aident = string

and avalue =
  | AInt of int
  | AFloat of float
  | AString of string
  | AIdent of aident
