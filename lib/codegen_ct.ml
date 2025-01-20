module CTerms = struct
  type cterm =
    | FVar of string * cterm
    | Apply of cterm * cterm
    | Abstr of string * cterm list * cterm
    | Value of value
  [@@deriving show]

  and value =
    | Int of int
    | Float of float
    | String of string
    | Ident of string
  [@@deriving show]

  type cterms = cterm list [@@deriving show]
end

type codegen =
  { a : Ast.ast
  ; g : CTerms.cterms
  }

and vars = (string, CTerms.cterm) Hashtbl.t

let add_term ~codegen:c term =
  let g = c.g @ [ term ] in
  { a = c.a; g }
;;

let new_codegen ~ast:a = { a; g = [] }

let rec codegen ~codegen:c =
  let rec codegen' c = function
    | [] -> List.rev c.g
    | node :: nodes ->
      let c, _ = codegen_node c node in
      codegen' c nodes
  in
  codegen' c c.a

and codegen_node c = function
  | Ast.AStmt stmt ->
    let c, term = codegen_stmt c stmt in
    { a = c.a; g = term :: c.g }, term
  | AExpr expr ->
    let c, term = codegen_expr c expr in
    { a = c.a; g = term :: c.g }, term
  | _ -> assert false

and codegen_stmt c = function
  | Ast.ALet (name, expr) ->
    let c, node = codegen_expr c expr in
    c, CTerms.FVar (name, node)
  | Ast.AFunc (name, params, body) -> codegen_func c name params body

and codegen_func c name params body =
  let c, params = codegen_params c params in
  let c, body = codegen_expr c body in
  let func_term = CTerms.Abstr (name, params, body) in
  c, func_term

and codegen_params c params =
  let rec codegen_params' c generated = function
    | [] -> c, List.rev generated
    | param :: params ->
      let c, param_term = codegen_param c param in
      codegen_params' c (param_term :: generated) params
  in
  codegen_params' c [] params

and codegen_param c param =
  let param_term = CTerms.Value (Ident param) in
  c, param_term

and codegen_expr c = function
  | Ast.AValue value -> codegen_value c value
  | _ -> assert false

and codegen_value c ast_value =
  let value =
    match ast_value with
    | AInt i -> CTerms.Int i
    | AFloat f -> Float f
    | AString s -> String s
    | AIdent id -> Ident id
  in
  c, CTerms.Value value
;;
