(**TODO: [Printing] Support depth like in blocks etc. *)

type ast = node list [@@deriving show]

and node =
  | AExpr of aexpr
  | AStmt of astmt
[@@deriving show]

and astmt =
  | ALet of alet
  | AFunc of afunc
  | AMatch of amatch
[@@deriving show]

and paramater = aident [@@deriving show]
and paramaters = paramater list [@@deriving show]

and aexpr =
  | AValue of avalue
  | ACall of acall
  | ABinary of abinary
  | ABlock of ablock
[@@deriving show]

and ablock = node list [@@deriving show]
and abinary = aexpr * aoperation * aexpr [@@deriving show]
and acall = aident * aexpr list [@@deriving show]
and amatch = aexpr * (aexpr * aexpr) list [@@deriving show]
and alet = aident * aexpr
and afunc = aident * paramaters * aexpr

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
  | ATrue
  | AFalse
[@@deriving show]

let rec string_of_ast nodes = String.concat "\n" (List.map string_of_node nodes)

and string_of_node = function
  | AExpr expr -> string_of_expr expr
  | AStmt stmt -> string_of_stmt stmt

and string_of_stmt = function
  | ALet (name, value) -> "let " ^ name ^ " = " ^ string_of_expr value
  | AFunc (name, params, value) ->
    "let " ^ name ^ "(" ^ string_of_params params ^ ")" ^ " = " ^ string_of_expr value
  | AMatch m -> string_of_match m

and string_of_expr = function
  | AValue v -> string_of_value v
  | ACall c -> string_of_call c
  | ABinary b -> string_of_binary b
  | ABlock b -> string_of_block b

and string_of_value = function
  | AInt i -> string_of_int i
  | AFloat f -> string_of_float f
  | AIdent n -> n
  | AString s -> "\"" ^ s ^ "\""
  | ATrue -> "true"
  | AFalse -> "false"

and string_of_call (name, args) = name ^ String.concat ", " (List.map string_of_expr args)

and string_of_binary (lhs, op, rhs) =
  string_of_expr lhs ^ " " ^ string_of_op op ^ " " ^ string_of_expr rhs

and string_of_match (against, body) =
  let rec string_of_match' = function
    | [] -> ""
    | (lhs, rhs) :: rest ->
      "| "
      ^ string_of_expr lhs
      ^ " -> "
      ^ string_of_expr rhs
      ^ "\n"
      ^ string_of_match' rest
  in
  "match " ^ string_of_expr against ^ "\n" ^ string_of_match' body

and string_of_block block =
  let rec string_of_block' = function
    | [] -> ""
    | node :: nodes -> string_of_node node ^ "\n" ^ string_of_block' nodes
  in
  "{\n" ^ string_of_block' block ^ "}\n"

and string_of_op = function
  | ADiv -> "/"
  | AEq -> "="
  | AEqEq -> "=="
  | ALess -> "<"
  | ALessEq -> "<="
  | AMore -> ">"
  | AMoreEq -> ">="
  | APlus -> "+"
  | ASub -> "-"
  | AMul -> "*"

and string_of_params = function
  | params -> String.concat ", " params
;;
