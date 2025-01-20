open Parse

let%expect_test "Test codegen for identity function" =
  let identity_ast = parse_str "let identity(x) = x " in
  let codegenerator = Codegen_ct.new_codegen ~ast:identity_ast in
  let generated = Codegen_ct.codegen ~codegen:codegenerator in
  print_string @@ Codegen_ct.CTerms.show_cterms generated;
  [%expect
    {|
    [(Codegen_ct.CTerms.Abstr ("identity",
        [(Codegen_ct.CTerms.Value (Codegen_ct.CTerms.Ident "x"))],
        (Codegen_ct.CTerms.Value (Codegen_ct.CTerms.Ident "x"))))
      ]
    |}]
;;
