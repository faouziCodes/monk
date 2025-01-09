type ast = AExpr of aexpr | AStmt
and astmt = ALet of aexpr * aexpr | ATypeDef of atypedef
and atypedef = (aexpr * aexpr) list

and aexpr =
  | AValue of avalue
  | ACall of acall
  | ABinary of abinary
  | AMatch of amatch
  | ABlock of ablock
  | TypeInstance of atypedef

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
