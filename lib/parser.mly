%token <int> INT
%token <float> FLOAT
%token <string> ID STRING
%token LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET LEFT_CBRACKET RIGHT_CBRACKET RIGHT_ARROW LEFT_ARROW EQ EQEQ LESS LESS_EQ MORE MORE_EQ COLON COMMA LET MATCH IF ELSE ELSE_IF EOF SUB PLUS MUL DIV PIPE TRUE FALSE

%left PLUS SUB
%left MUL DIV

%start <Ast.ast> prog
%%

prog:
    |  l =  list(stmt); EOF; { l }

stmt:
    | m = matches { Ast.AStmt(m) }
    | f = fn_node { Ast.AStmt(f) }
    | l = let_node { Ast.AStmt(l) }
    | e = expr { Ast.AExpr(e) }

let_node:
    | LET; i = ident; EQ; e = expr; { ALet(i, e) }

fn_node:
    | LET s = ident p = paramaters EQ b = expr { AFunc(s, p, b) }

expr:
    | l = expr o = op r = expr { ABinary(l, o, r) }
    | v = value { AValue(v) }
    | c = call { ACall(c) }
    | b = block { ABlock(b) }


value:
    | i  = INT { Ast.AInt(i) }
    | f  = FLOAT {  Ast.AFloat(f) }
    | s  = STRING {  Ast.AString(s) }
    | l  = ident {  Ast.AIdent(l) }
    | TRUE { Ast.ATrue }
    | FALSE { Ast.AFalse }

call:
    |  i = ident; LEFT_BRACE; a = args; RIGHT_BRACE; { i, a }

matches:
    | MATCH c = expr  l = list(mcase)  { Ast.AMatch(c, l) }

mcase:
    | PIPE lhs = expr; RIGHT_ARROW; rhs = expr; { lhs, rhs }

block:
    | LEFT_CBRACKET; s = list(stmt) ; RIGHT_CBRACKET { s }

args:
    | a = separated_list(COMMA, expr) { a }

ident:
    | i =  ID { i }

paramaters:
    | LEFT_BRACE params = separated_list(COMMA, ident) RIGHT_BRACE { params }

%inline op:
    | PLUS { Ast.APlus }
    | SUB { Ast.ASub }
    | MUL { Ast.AMul }
    | DIV { Ast.ADiv }
