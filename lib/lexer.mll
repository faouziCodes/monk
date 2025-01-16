{
        open Parser
        exception SyntaxError of string
}

let digit = ['0'-'9']

let int = '-'? ['0'-'9'] digit*
let frac = '.' digit*
let float = digit* frac?
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token =
        parse
        | '|' { PIPE }
        | '+' { PLUS }
        | '-' { SUB }
        | '*' { MUL }
        | '/' { DIV }
        | '(' { LEFT_BRACE }
        | ')' { RIGHT_BRACE }
        | '[' { LEFT_BRACKET }
        | ']' { RIGHT_BRACKET }
        | '{' { LEFT_CBRACKET }
        | '}' { RIGHT_CBRACKET }
        | "<-" { LEFT_ARROW }
        | "->" { RIGHT_ARROW }
        | '=' { EQ }
        | "==" { EQEQ }
        | '<' { LESS }
        | "<=" { LESS_EQ }
        | '>' { MORE }
        | ">=" { MORE_EQ }
        | ":" { COLON }
        | "," { COMMA }
        | "let" { LET }
        | "match" { MATCH }
        | "if" { IF }
        | "else" { ELSE }
        | "elif" { ELSE_IF }
        | white { token lexbuf }
        | newline { token lexbuf }
        | int { INT(int_of_string (Lexing.lexeme lexbuf)) } 
        | float { FLOAT(float_of_string (Lexing.lexeme lexbuf)) } 
        | id { ID (Lexing.lexeme lexbuf) }
        | eof { EOF }
         | '"'
         { let buffer = Buffer.create 1 in
           STRING (read_string buffer lexbuf)
         }
        and read_string buf =
          parse
          | '"'       {  (Buffer.contents buf) }
          | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
          | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
          | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
          | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
          | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
          | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
          | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
          | [^ '"' '\\']+
            { Buffer.add_string buf (Lexing.lexeme lexbuf);
              read_string buf lexbuf
            }
          | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
          | eof { raise (SyntaxError ("String is not terminated")) }
