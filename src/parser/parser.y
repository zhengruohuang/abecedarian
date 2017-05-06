%{

#include "ast.h"

extern int yylex();

void yyerror(const char *s);

struct list *new_list();
int append_to_list(struct list *list, void *node, enum node_type type);

struct func_node *new_func(char *name, int exported, struct list *param_list);
struct class_node *new_class(char *name, int exported, struct list *parent_list);
struct name_node *new_name(char *text);
struct value_node *new_value(char *text);

%}


/*
 * YYSTYPE
 */
%union {
    char *name;
    char *value;
    
    struct program_node *program_node;
    struct func_node *func_node;
    struct class_node *class_node;
    struct expr_node *expr_node;
    struct name_node *name_node;
    struct value_node *value_node;
}

/*
 * Token
 */
%token KEY_USE KEY_AS KEY_CLASS KEY_IS KEY_IN
%token KEY_VAR KEY_FUNC
%token KEY_IF KEY_ELSE KEY_FOREACH KEY_FOR KEY_DO KEY_WHILE KEY_SWITCH KEY_CASE KEY_DEFAULT KEY_BREAK KEY_CONT KEY_CONV KEY_RET
%token OP_ASSIGN
%token OP_EQ OP_NE OP_LT OP_LE OP_GT OP_GE
%token OP_LAND OP_LOR OP_LNOT
%token OP_ADD OP_SUB OP_MUL OP_DIV OP_BAND OP_BOR OP_BXOR OP_BNOT

%token TOK_LP TOK_RP TOK_LB TOK_RB TOK_LA TOK_RA
%token TOK_DOT TOK_COMMA TOK_SEMI

%token TOK_NAME VAL_INT VAL_FLOAT VAL_STRING

/*
 * Node
 */

/*
 * Operator precedence
 */
%left ':' '?'
%right THEN KEY_ELSE
%left OP_ASSIGN OP_ADD_ASSIGN OP_SUB_ASSIGN OP_MUL_ASSIGN OP_DIV_ASSIGN OP_MOD_ASSIGN OP_AND_ASSIGN OP_OR_ASSIGN OP_XOR_ASSIGN OP_LSHIFT_ASSIGN OP_RSHIFT_ASSIGN
%left OP_LOGIC_AND OP_LOGIC_OR
%left OP_LESS OP_LESS_EQ OP_GREATER OP_GREATER_EQ OP_EQUAL OP_NOT_EQUAL
%left OP_ADD OP_SUB OP_XOR OP_AND OP_OR OP_LSHIFT OP_RSHIFT
%left OP_MUL OP_DIV OP_MOD
%left OP_INC OP_DEC
%left OP_LOGIC_NOT OP_NOT
%left '.' '[' '('

/*
 * Entry point
 */
%start program


%%


/*
 * Program
 */
program
    : program_stmts
    ;

program_stmts
    : program_stmt
    | program_stmts program_stmt
    ;

program_stmt
    : var_dec ';'
    | module ';'
    | class_dec ';'
    | func
    ;


/*
 * Module
 */
module
    : KEY_USE TOK_NAME
    | KEY_USE TOK_NAME KEY_AS TOK_NAME
    ;


/*
 * Variable
 */
var_dec
    : KEY_VAR var_list
    ;

var_list
    : var_id
    | var_list ',' var_id
    ;

var_id
    : TOK_NAME
    | TOK_NAME OP_ASSIGN expr
    ;


/*
 * Function
 */
func
    : func_dec block    { $$ = $1; $$->body = $2; }
    ;

func_dec
    : KEY_FUNC TOK_NAME '(' ')'             { $$ = new_func($2, 1, NULL); }
    | KEY_FUNC TOK_NAME '(' func_params ')' { $$ = new_func($2, 1, $4); }
    ;

func_params
    : TOK_NAME
    | TOK_NAME ',' func_params
    ;


/*
 * Class
 */
class_dec
    : KEY_CLASS TOK_NAME '{' class_stmts '}'
    | KEY_CLASS TOK_NAME ':' class_parents '{' class_stmts '}'
    ;

class_parents
    : TOK_NAME
    | class_parents TOK_NAME
    ;

class_stmts
    : class_stmt
    | class_stmt class_stmts
    ;

class_stmt
    : var_dec ';'
    | func
    ;


/*
 * Block
 */
block
    : '{' '}'
    | '{' stmts '}'
    ;

stmts
    : stmt
    | stmt stmts
    ;

stmt
    : ';'
    | var_dec ';'
    | expr ';'
    | block
    | ctrl
    ;


/*
 * expr
 */
expr_list
    : expr
    | expr_list ',' expr
    ;

expr
    : id_name
    | value
    
    /* Arithmetic */
    | expr OP_ADD expr
    | expr OP_SUB expr
    | expr OP_MUL expr
    | expr OP_DIV expr
    | expr OP_MOD expr
    | expr OP_XOR expr
        
    /* Self Add/Sub */
    | expr OP_INC
    | expr OP_DEC
    | OP_INC expr
    | OP_DEC expr
    
    /* Unary */
    | OP_ADD expr
    | OP_SUB expr
    | OP_NOT expr
    | OP_LOGIC_NOT expr
    
    /* Logic */
    | expr OP_GREATER expr
    | expr OP_GREATER_EQ expr
    | expr OP_LESS expr
    | expr OP_LESS_EQ expr
    | expr OP_EQUAL expr
    | expr OP_NOT_EQUAL expr

    | expr OP_LOGIC_AND expr
    | expr OP_LOGIC_OR expr
    
    /* Bit */
    | expr OP_AND expr
    | expr OP_OR expr

    | expr OP_LSHIFT expr
    | expr OP_RSHIFT expr
    
    /* Assign */
    | expr OP_ASSIGN expr
    | expr OP_ADD_ASSIGN expr
    | expr OP_SUB_ASSIGN expr
    | expr OP_MUL_ASSIGN expr
    | expr OP_DIV_ASSIGN expr
    | expr OP_MOD_ASSIGN expr
    | expr OP_AND_ASSIGN expr
    | expr OP_OR_ASSIGN expr
    | expr OP_XOR_ASSIGN expr
    | expr OP_LSHIFT_ASSIGN expr
    | expr OP_RSHIFT_ASSIGN expr
    
    /* Tenary */
    | expr '?' expr ':' expr
    
    /* Element */
    | expr '.' expr
    
    /* Array */
    | expr '[' expr ']'
    
    /* Parentheses */
    | '(' expr ')'
    
    /* Func call */
    | expr '(' ')'
    | expr '(' func_args ')'
    ;

func_args
    : expr
    | expr ',' func_args
    ;

value_str
    : VAL_STRING
    | value_str VAL_STRING
    ;

value
    : value_str { /* FIXME */ }
    | VAL_INT   { $$ = new_value($1); }
    | VAL_FLOAT { $$ = new_value($1); }
    ;

id_name
    : TOK_NAME  { $$ = new_name($1); }
    ;


/*
 * Control flow
 */
ctrl
    : ctrl_if
    | ctrl_foreach
    | ctrl_for
    | ctrl_do
    | ctrl_while
    | ctrl_switch
    | ctrl_break
    | ctrl_continue
    | ctrl_converge
    | ctrl_return
    ;

/* If */
ctrl_if
    : KEY_IF '(' expr_list ')' stmt %prec THEN
    | KEY_IF '(' expr_list ')' stmt KEY_ELSE stmt
    ;

/* For & foreach */
for_init
    :
    | var_dec
    | expr_list
    ;

for_cond
    :
    | expr_list
    ;

for_iter
    :
    | expr_list
    ;

ctrl_for
    : KEY_FOR '(' for_init ';' for_cond ';' for_iter ')' stmt
    ;

ctrl_foreach
    : KEY_FOREACH '(' var_dec KEY_IN expr_list ')' stmt
    ;

/* Do & while */
ctrl_do
    : KEY_DO block KEY_WHILE '(' expr_list ')' ';'
    ;

ctrl_while
    : KEY_WHILE '(' expr_list ')' stmt
    ;

/* Switch */
ctrl_switch
    : KEY_SWITCH '(' expr_list ')' '{' case_list '}'
    ;

case_list
    : case_item
    | case_list case_item
    ;

case_item
    : case_branch
    | case_default
    ;

case_default
    : KEY_DEFAULT ':' stmts
    ;

case_branch
    : KEY_CASE expr ':'
    | KEY_CASE expr ':' stmts
    ;

/* General */
ctrl_break
    : KEY_BREAK ';'
    | KEY_BREAK expr ';'
    ;

ctrl_continue
    : KEY_CONT ';'
    | KEY_CONT expr ';'
    ;

ctrl_converge
    : KEY_CONV ';'
    | KEY_CONV expr ';'
    ;

ctrl_return
    : KEY_RET ';'
    | KEY_RET expr ';'
    ;


%%


void yyerror(const char* err)
{
    printf("\nError:%s\n", err);
}

struct list *new_list()
{
    struct list *l = (struct list *)malloc(sizeof(struct list));
    assert(l);
    
    l->tail = l->head = NULL;
    l->count = 0;
    
    return l;
}

int append_to_list(struct list *list, enum node_type type, void *node)
{
    struct list_node *ln = (struct list_node *)malloc(sizeof(struct list_node));
    assert(ln);
    
    ln->type = type;
    ln->node = node;
    
    ln->prev = list->tail;
    ln->next = NULL;
    list->tail = ln;
    if (!list->head) {
        list->head = ln;
    }
    
    list->count++;
    
    return 0;
}
