(**Tree interpreter may be used to find faults in the program before compilation, identify optimization points and allow for features in the feature. *)

(**Standard functions, for now these are the way I inject functions from the outside.*)

type interpreter = { e : env }

and env =
  { gf : ifuncs
  ; gv : ivars
  ; s : scope option
  ; stdf : (string, std_funcs) Hashtbl.t
  }

and scope =
  { p : scope option
  ; f : ifuncs
  ; v : ivars
  }

and ifuncs = (string, Ast.afunc) Hashtbl.t
and ivars = (string, ivalue) Hashtbl.t

and ivalue =
  | IInt of int
  | IFloat of float
  | Iident of string
  | IString of string
  | ITrue
  | IFalse
  | Unit

and std_funcs = { c : ivalue list -> ivalue }

type eval_error =
  | NoSuchVar of string
  | NoSuchFunc of string
  | NotImplemented of inot_implemented

and inot_implemented =
  | IAdd
  | IDiv
  | IMul
  | ISub

let ibool_of_bool = function
  | true -> ITrue
  | false -> IFalse
;;

exception EvalError of eval_error

let new_scope p = { p; f = Hashtbl.create 20; v = Hashtbl.create 20 }
let no_such_func name = raise (EvalError (NoSuchFunc name))
let no_such_var name = raise (EvalError (NoSuchVar name))

let register_var env name value =
  match env.s with
  | Some s -> Hashtbl.add s.v name value
  | None -> Hashtbl.add env.gv name value
;;

let register_func env (name, params, body) =
  match env.s with
  | Some s -> Hashtbl.add s.f name (name, params, body)
  | None -> Hashtbl.add env.gf name (name, params, body)
;;

let rec get_var_scope s name =
  match s.p, Hashtbl.find_opt s.v name with
  | Some v, None -> get_var_scope v name
  | _, Some v -> Some v
  | _ -> None
;;

let get_var env name =
  try
    match env.s with
    | Some s ->
      (match get_var_scope s name with
       | Some v -> v
       | None -> Hashtbl.find env.gv name)
    | None -> Hashtbl.find env.gv name
  with
  | Not_found -> no_such_var name
;;

let get_std_func env name = Hashtbl.find_opt env.stdf name

let increase_depth interpreter =
  let e =
    { s = Some (new_scope interpreter.e.s)
    ; gv = interpreter.e.gv
    ; gf = interpreter.e.gf
    ; stdf = interpreter.e.stdf
    }
  in
  { e }
;;

let decrease_depth interpreter =
  let s =
    match interpreter.e.s with
    | Some s -> s.p
    | None -> None
  in
  let e =
    { s; gv = interpreter.e.gv; gf = interpreter.e.gf; stdf = interpreter.e.stdf }
  in
  { e }
;;

let find_func env name =
  try Hashtbl.find env.gf name with
  | Not_found -> no_such_func name
;;

let eval_add lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> IInt (lhs + rhs)
  | IFloat lhs, IFloat rhs -> IFloat (lhs +. rhs)
  | IString lhs, IString rhs -> IString (lhs ^ rhs)
  | _ -> raise (EvalError (NotImplemented IAdd))
;;

let ( ^+ ) = eval_add

let eval_sub lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> IInt (lhs - rhs)
  | IFloat lhs, IFloat rhs -> IFloat (lhs -. rhs)
  | IString lhs, IString rhs -> IString (lhs ^ rhs)
  | _ -> raise (EvalError (NotImplemented IAdd))
;;

let ( ^- ) = eval_sub

let eval_div lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> IInt (lhs / rhs)
  | IFloat lhs, IFloat rhs -> IFloat (lhs /. rhs)
  | _ -> raise (EvalError (NotImplemented IDiv))
;;

let ( ^/ ) = eval_div

let eval_mul lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> IInt (lhs * rhs)
  | IFloat lhs, IFloat rhs -> IFloat (lhs *. rhs)
  | _ -> raise (EvalError (NotImplemented IDiv))
;;

let ( ^* ) = eval_mul

let eval_more lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> ibool_of_bool (lhs > rhs)
  | IFloat lhs, IFloat rhs -> ibool_of_bool (lhs > rhs)
  | _ -> raise (EvalError (NotImplemented IDiv))
;;

let ( ^> ) = eval_more

let eval_more_eq lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> ibool_of_bool (lhs >= rhs)
  | IFloat lhs, IFloat rhs -> ibool_of_bool (lhs >= rhs)
  | _ -> raise (EvalError (NotImplemented IDiv))
;;

let ( ^>= ) = eval_more_eq

let eval_less lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> ibool_of_bool (lhs < rhs)
  | IFloat lhs, IFloat rhs -> ibool_of_bool (lhs < rhs)
  | _ -> raise (EvalError (NotImplemented IDiv))
;;

let ( ^< ) = eval_less

let eval_less_eq lhs rhs =
  match lhs, rhs with
  | IInt lhs, IInt rhs -> ibool_of_bool (lhs <= rhs)
  | IFloat lhs, IFloat rhs -> ibool_of_bool (lhs <= rhs)
  | _ -> raise (EvalError (NotImplemented IDiv))
;;

let ( ^<= ) = eval_less_eq

let rec eval interpreter ast =
  let eval' _ = function
    | _ -> assert false
  in
  eval' interpreter ast

and eval_node interpreter = function
  | Ast.AStmt stmt -> eval_stmt interpreter stmt
  | Ast.AExpr expr -> interpreter, eval_expr interpreter expr

and eval_stmt interpreter = function
  | ALet (name, value) -> eval_let_stmt interpreter name value
  | AFunc func ->
    register_func interpreter.e func;
    interpreter, Unit

and eval_let_stmt interpreter name value =
  try
    let value = eval_expr interpreter value in
    register_var interpreter.e name value;
    interpreter, Unit
  with
  | EvalError _ -> assert false

and eval_expr interpreter expr =
  match expr with
  | ACall c -> eval_call interpreter c
  | AValue v -> eval_value interpreter v
  | ABinary b -> eval_binary interpreter b
  | AMatch (value, cases) -> eval_match interpreter (eval_expr interpreter value) cases
  | ABlock b -> eval_block interpreter b

and eval_call interpreter (name, args) =
  match get_std_func interpreter.e name with
  | Some stdf ->
    let args = List.map (eval_expr interpreter) args in
    stdf.c args
  | None ->
    let _, params, body = find_func interpreter.e name in
    let interpreter = increase_depth interpreter in
    List.iter2
      (fun par arg -> eval_expr interpreter arg |> register_var interpreter.e par)
      params
      args;
    eval_expr interpreter body

and eval_value interpreter = function
  | Ast.AInt i -> IInt i
  | Ast.AFloat f -> IFloat f
  | Ast.AString s -> IString s
  | Ast.AIdent s -> get_var interpreter.e s
  | Ast.ATrue -> ITrue
  | Ast.AFalse -> IFalse

and eval_binary interpreter = function
  | lhs, AEqEq, rhs ->
    ibool_of_bool (eval_expr interpreter lhs = eval_expr interpreter rhs)
  | lhs, AMore, rhs -> eval_expr interpreter lhs ^> eval_expr interpreter rhs
  | lhs, AMoreEq, rhs -> eval_expr interpreter lhs ^>= eval_expr interpreter rhs
  | lhs, ALess, rhs -> eval_expr interpreter lhs ^< eval_expr interpreter rhs
  | lhs, ALessEq, rhs -> eval_expr interpreter lhs ^<= eval_expr interpreter rhs
  | lhs, APlus, rhs -> eval_expr interpreter lhs ^+ eval_expr interpreter rhs
  | lhs, ASub, rhs -> eval_expr interpreter lhs ^- eval_expr interpreter rhs
  | lhs, ADiv, rhs -> eval_expr interpreter lhs ^/ eval_expr interpreter rhs
  | lhs, AMul, rhs -> eval_expr interpreter lhs ^* eval_expr interpreter rhs
  | _ -> assert false

and eval_match interpreter value = function
  | [] -> Unit
  | (case, body) :: _ when eval_expr interpreter case = value ->
    eval_expr interpreter body
  | _ :: cases -> eval_match interpreter value cases

and eval_block interpreter block =
  let interpreter = increase_depth interpreter in
  let rec eval_block' interpreter = function
    | [] -> Unit
    | [ node ] ->
      let _, body = eval_node interpreter node in
      body
    | node :: nodes ->
      let interpreter, _ = eval_node interpreter node in
      eval_block' interpreter nodes
  in
  eval_block' interpreter block
;;
