%token <int> INT
%token <float> FLOAT
%token <string> ID STRING
%token LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET LEFT_CBRACKET RIGHT_CBRACKET RIGHT_ARROW LEFT_ARROW EQ EQEQ LESS LESS_EQ MORE MORE_EQ COLON COMMA LET MATCH IF ELSE ELSE_IF EOF SUB PLUS MUL DIV PIPE
%start <Ast.node> prog
%%

prog:
    | EOF { EOP }
    | l = stmt { Ast.AStmt(l) }

stmt:
    | l = let_node { l }
    | f = fn_node { f }



let_node:
    | LET; i = ident; EQ; e = expr; { ALet(i, e) }

fn_node:
    | s = ident; p = paramaters; b =  stmt { AFunc(s, p, b) }

expr:
    | v = value { AValue(v) }
    | c = call { ACall(c) }
    | b = binary { ABinary(b) }
    | m = matches { AMatch(m) }
    | b = block { ABlock(b) }

binary:
    | l = expr; o = operators; r= expr; { l, o, r}

value:
    | i  = INT; { Ast.AInt(i) }
    | f  = FLOAT; {  Ast.AFloat(f) }
    | s  = STRING; {  Ast.AString(s) }
    | l  = ident; {  Ast.AIdent(l) }

call:
    | i = ident; LEFT_BRACE; a = args; RIGHT_BRACE; { i, a }

matches:
    | MATCH; l = separated_list(PIPE, mcase); { l }

mcase:
    | lhs = expr; RIGHT_ARROW; rhs = expr; { lhs, rhs }

block: 
    | LEFT_CBRACKET; s = list(stmt) ; RIGHT_CBRACKET { s }

args:
    | a = separated_list(COMMA, expr) { a }

ident:
    | i =  ID { i }

paramaters:
    | params = separated_list(COMMA, ident) { params }

operators:
    | EQ { Ast.AEq }
    | EQ; EQ; { Ast.AEqEq }
    | LESS { Ast.ALess }
    | LESS_EQ { Ast.ALessEq }
    | MORE { Ast.AMore }
    | MORE_EQ { Ast.AMoreEq}
    | PLUS { Ast.APlus }
    | SUB { Ast.ASub }
    | MUL { Ast.AMul }
    | DIV { Ast.ADiv }
