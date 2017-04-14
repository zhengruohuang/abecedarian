%{

int cur_line = 0;
int cur_col = 0;

%}


/* States */
%x COMMENT


%%

[ \t\n]         { }

"//".*          { }

"/*"            { BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL) }
<COMMENT>\n     { cur_line++; }
<COMMENT>.      { }

"import"        { return KEY_IMPORT; }
"as"            { return KEY_AS; }
"is"            { return KEY_IS; }

"class"         { return KEY_CLASS; }
"var"           { return KEY_VAR; }
"func"          { return KEY_FUNC; }

"if"            { return KEY_IF; }
"foreach"       { return KEY_FOREACH; }
"for"           { return KEY_FOR; }
"while"         { return KEY_WHILE; }
"break"         { return KEY_BREAK; }
"continue"      { return KEY_CONT; }
"return"        { return KEY_RET; }

"="         { return OP_ASSIGN; }

"=="            { return OP_EQ; }
"!="            { return OP_NE; }
"<"         { return OP_LT; }
"<="            { return OP_LE; }
">"         { return OP_GT; }
">="            { return OP_GE; }

"&&"            { return OP_LAND; }
"||"            { return OP_LOR; }
"!"         { return OP_LNOT; }

"+"         { return OP_ADD; }
"-"         { return OP_SUB; }
"*"         { return OP_MUL; }
"/"         { return OP_DIV; }

"&"         { return OP_BAND; }
"|"         { return OP_BOR; }
"^"         { return OP_BXOR; }
"~"         { return OP_BNOT; }

"("         { return TOK_LP; }
")"         { return TOK_RP; }
"{"         { return TOK_LB; }
"}"         { return TOK_RB; }
"["         { return TOK_LA; }
"]"         { return TOK_RA; }

"."         { return TOK_DOT; }
","         { return TOK_COMMA; }
";"         { return TOK_SEMI; }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.name = strdup(yytext); return TOK_NAME; }
[0-9]+\.[0-9]*      { yylval.val_int = atoi(yytext); return NUM_FLOAT; }
[0-9]+          { yylval.val_int = atoi(yytext); return NUM_INT; }

.           { printf("Unknown token: %s\n", yytext); yyterminate(); }

%%
