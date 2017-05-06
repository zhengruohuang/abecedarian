#ifndef __AST_H__
#define __AST_H__


/*
 * List
 */
enum node_type {
    nt_unknown,
};

struct list_node {
    enum node_type type;
    void *node;
    
    struct list_node *prev;
    struct list_node *next;
};

struct list {
    struct list_node *head;
    struct list_node *tail;
    int count;
};


/*
 * Program
 */
struct program_node {
    char *scope_name;
    
    struct list *stmt_list;
    struct list *func_list;
    struct list *class_list;
};

struct func_node {
    struct list *stmt_list;
};

struct class_node {
    struct list *var_list;
    struct list *func_list;
};


/*
 * Statement
 */
struct stmt_node {
    struct list *content_list;
};

struct block_node {
    struct list *stmt_list;
};


/*
 * Control
 */
struct if_node {
    struct stmt_node *cond;
    struct stmt_node *then_body;
    struct stmt_node *else_body;
};

struct for_node {
    struct stmt_node *init;
    struct stmt_node *cond;
    struct stmt_node *iter;
    struct stmt_node *body;
};

struct do_node {
    struct stmt_node *cond;
    struct stmt_node *body;
};

struct while_node {
    struct stmt_node *cond;
    struct stmt_node *body;
};

struct switch_node {
    struct stmt_node *value;
    struct list *case_list;
    struct stmt_node *def;
};

struct case_node {
    struct stmt_node *value;
    struct stmt_node *body;
};


/*
 * Expression
 */
enum op_type {
    ot_none,
    ot_add,
};

enum expr_type {
    et_empty,
    et_name,
    et_value,
    et_expr,
};

enum value_type {
    vt_null,
    vt_int,
    vt_float,
    vt_str,
};

struct expr_node {
    enum op_type op;
    
    struct {
        enum expr_type type;
        union {
            struct name_node *name;
            struct value_node *value;
            struct expr_node *expr;
        };
    } left;
    
    struct {
        enum expr_type type;
        union {
            struct name_node *name;
            struct value_node *value;
            struct expr_node *expr;
        };
    } right;
};

struct name_node {
    char *text;
};

struct value_node {
    enum value_type type;
    char *text;
    union {
        char *value_str;
        unsigned long long value_int;
        double value_float;
    };
};


#endif
