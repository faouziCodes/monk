open Term

type codegen_terms =
  { a : Ast.ast
  ; g : variables
  ; s : scoped
  }

and scoped = { p : scoped option }
and variables = (string, term) Hashtbl.t

let new_scope p = { p }
let new_cg ~ast:a = { a; g = Hashtbl.create 99; s = new_scope None }

let rec codegen ~cg:c = List.map (codegen_node c) c.a

and codegen_node c = function
  | Ast.AExpr e -> codegen_expr c e
  | _ -> assert false

and codegen_expr _c = function
  (*| Ast.AValue v -> codegen_value*)
  | _ -> assert false
;;
