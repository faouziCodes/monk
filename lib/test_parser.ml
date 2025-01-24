open Parse

let%expect_test "Test parser let" =
  let test_str = parse_str "let x = 10" in
  print_endline @@ Ast.show_ast test_str;
  [%expect {| [(Ast.AStmt (Ast.ALet ("x", (Ast.AValue (Ast.AInt 10)))))] |}]
;;

let%expect_test "Test parser function" =
  let test_str = parse_str "let x(a, b) = {\n  a * b + a\n  a* b}" in
  print_endline @@ Ast.show_ast test_str;
  [%expect
    {|
    [(Ast.AStmt
        (Ast.AFunc
           ("x", ["a"; "b"],
            (Ast.ABlock
               [(Ast.AExpr
                   (Ast.ABinary
                      ((Ast.ABinary
                          ((Ast.AValue (Ast.AIdent "a")), Ast.AMul,
                           (Ast.AValue (Ast.AIdent "b")))),
                       Ast.APlus, (Ast.AValue (Ast.AIdent "a")))));
                 (Ast.AExpr
                    (Ast.ABinary
                       ((Ast.AValue (Ast.AIdent "a")), Ast.AMul,
                        (Ast.AValue (Ast.AIdent "b")))))
                 ]))))
      ]
    |}]
;;

let%expect_test "Test function call" =
  let test_str = parse_str "add(10, 20)" in
  print_endline @@ Ast.show_ast test_str;
  [%expect
    {|
    [(Ast.AExpr
        (Ast.ACall
           ("add", [(Ast.AValue (Ast.AInt 10)); (Ast.AValue (Ast.AInt 20))])))
      ]
    |}]
;;

let%expect_test "Test function call" =
  let test_str = parse_str {|add("x,y,z", 20)|} in
  print_endline @@ Ast.show_ast test_str;
  [%expect
    {|
    [(Ast.AExpr
        (Ast.ACall
           ("add",
            [(Ast.AValue (Ast.AString "x,y,z")); (Ast.AValue (Ast.AInt 20))])))
      ]
    |}]
;;

let%expect_test "Test parser expr" =
  let test_str = parse_str "10 + 10" in
  print_endline @@ Ast.show_ast test_str;
  [%expect
    {|
    [(Ast.AExpr
        (Ast.ABinary
           ((Ast.AValue (Ast.AInt 10)), Ast.APlus, (Ast.AValue (Ast.AInt 10)))))
      ]
    |}]
;;
