type term = Var of string | Abstr of string * term | Apply of term * term
[@@deriving show]

let rec rewrite term pat change =
  match term with
  | term when term = pat -> change
  | Abstr (bound, body) -> Abstr (bound, rewrite body pat change)
  | Apply (lhs, rhs) -> Apply (rewrite lhs pat change, rewrite rhs pat change)
  | Var x -> Var x

let rec reduce = function
  | Abstr (bound, body) -> Abstr (bound, body)
  | Apply (Abstr (bound_var, body), argument) ->
      rewrite body (Var bound_var) argument |> reduce
  | Var x -> Var x
  | _ -> raise (Invalid_argument "Cannot reduce term provided")

let%expect_test "Test if reduction works correctly, identity_function" =
  print_endline @@ show_term @@ reduce (Apply (Abstr ("x", Var "x"), Var "10"));
  [%expect {| (Term.Var "10") |}]

let%expect_test "Identity To Identiy" =
  print_endline @@ show_term
  @@ reduce (Apply (Abstr ("x", Var "x"), Abstr ("z", Var "z")));
  [%expect {| (Term.Abstr ("z", (Term.Var "z"))) |}]

module DeBruijn = struct
  type dterm =
    | DFreeVar of string
    | DBoundVar of { mutable t : int }
    | DAbstr of dterm * dterm
    | DApply of dterm * dterm
  [@@deriving show]

  type env = { vars : (string * dterm) list }

  let new_env () = { vars = [] }
  let add_var env var term = { vars = (var, term) :: env.vars }
  let new_dbvar () = DBoundVar { t = 0 }

  let inc_level env =
    List.iter
      (fun (_, bound_var) ->
        match bound_var with
        | DBoundVar bound_var -> bound_var.t <- bound_var.t + 1
        | _ -> ())
      env.vars

  let get_bound_var env name =
    List.find_opt (fun (named, _) -> named = name) env.vars

  let rec convert env = function
    | Abstr (named_bound_var, body) ->
        inc_level env;
        let unamed_bound_var = new_dbvar () in
        let env = add_var env named_bound_var unamed_bound_var in
        DAbstr (unamed_bound_var, convert env body)
    | Apply (lhs, rhs) -> DAbstr (convert env lhs, convert env rhs)
    | Var x -> (
        match get_bound_var env x with
        | Some (_, bound) -> bound
        | None -> DFreeVar x)

  let%expect_test "Test if the conversion of normal lambda to debruijn indices \
                   works" =
    let term =
      Abstr
        ("x", Apply (Abstr ("y", Var "x"), Abstr ("y", Abstr ("x", Var "x"))))
    in
    let env = new_env () in
    print_endline (show_dterm (convert env term));
    [%expect
      {|
      (Term.DeBruijn.DAbstr (Term.DeBruijn.DBoundVar {t = 3},
         (Term.DeBruijn.DAbstr (
            (Term.DeBruijn.DAbstr (Term.DeBruijn.DBoundVar {t = 0},
               Term.DeBruijn.DBoundVar {t = 3})),
            (Term.DeBruijn.DAbstr (Term.DeBruijn.DBoundVar {t = 1},
               (Term.DeBruijn.DAbstr (Term.DeBruijn.DBoundVar {t = 0},
                  Term.DeBruijn.DBoundVar {t = 0}))
               ))
            ))
         ))
      |}]
end
