open Lexer
open Parser

let lex text =
  let text = Lexing.from_string text in
  let rec lex' text tokens =
    match token text with
    | EOF -> List.rev tokens
    | other -> lex' text (other :: tokens)
  in
  lex' text
;;
