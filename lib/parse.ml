let parse_str source =
  let lexing = Lexing.from_string source in
  let stmts = Parser.prog Lexer.token lexing in
  stmts
;;
