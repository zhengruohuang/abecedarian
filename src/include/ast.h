#ifndef __AST_H__
#define __AST_H__


struct single_list {
    void *node;
    struct single_list *next;
};


/*
 * Program
 */
struct program_node {
    char *scope_name;
    
    struct single_list *stmt_list;
    struct single_list *func_list;
    struct single_list *class_list;
};

struct func_node {
    struct single_list *stmt_list;
};

struct class_node {
    struct single_list *var_list;
    struct single_list *func_list;
};


/*
 * Statement
 */
struct stmt_node {
    
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
