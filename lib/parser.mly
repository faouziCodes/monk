%token <int> INT
%token <float> FLOAT
%token <string> ID
%token <string> STRING
%token LEFT_BRACE
%token RIGHT_BRACE
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token LEFT_CBRACKET
%token RIGHT_CBRACKET
%token RIGHT_ARROW
%token LEFT_ARROW
%token EQ
%token EQEQ
%token LESS
%token LESS_EQ
%token MORE
%token MORE_EQ
%token COLON
%token COMMA
%token LET
%token MATCH
%token IF
%token ELSE
%token ELSE_IF
%token EOF
%start <Ast.ast option> prog
%%

prog:
                | EOF { None}
