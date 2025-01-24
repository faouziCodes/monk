let%expect_test "Test ast printer" =
  let ast = Parse.parse_str "let x(a, b) = {\n  a * b + a\n  a* b}" in
  let str = Ast.string_of_ast ast in
  print_string str
;;
