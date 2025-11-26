const std = @import("std");
const token_types = @import("token.zig");


const Grammer = @This();

pub const Program = struct{ decl: []Declaration };    

pub const Declaration = union(enum){
    ClassDecl: struct{ name: token_types.Token, subclass: ?token_types.Token, func: []Utility.Function, },
    FuncDecl: struct{ func: Utility.Function },
    VarDecl: struct{ name: token_types.Token, expr: Expression, }, 
};

pub const Statement = union(enum){
    ExprStmt: struct{ expr: Expression, },
    ForStmt: struct{ var_decl: ?Declaration.VarDecl, expr_stmt: ?Statement.ExprStmt, cond: ?Expression, incr: ?Expression, stmt: Statement, },
    IfStmt: struct{ cond: Expression, main_stmt: Statement, else_stmt: ?Statement, },
    PrintStmt: struct{ expr: Expression, },
    ReturnStmt: struct{ expr: ?Expression, },
    WhileStmt: struct{ cond: Expression, stmt: Statement },
    Block: struct{ decl: []Declaration, },
};

pub const Expression = union(enum){
    Assignment: struct{ call: ?Expression.Call, name: token_types.Token, asgmt: ?Expression.Assignment, logic_or: ?Expression.LogicOr, },
    LogicOr: struct{ primary: Expression.LogicAnd, secondary: ?[]Expression.LogicAnd, },
    LogicAnd: struct{ primary: Expression.Equality, secondary: ?[]Expression.Equality, },
    Equality: struct{ primary: Expression.Comparison, secondary: ?[]Expression.Comparison, },
    Comparison: struct{ primary: Expression.Term, secondary: ?[]Expression.Term, },
    Factor: struct{ primary: Expression.Unary, secondary: ?[]Expression.Unary, },
    Unary: struct{ unary: ?Expression.Unary, call: ?Expression.Call, },
    Call: struct{ primary: Expression.Primary, args: ?[]Utility.Arguments, secondary: ?[]token_types.Token, },
    Primary: struct{ literal: ?token_types.Token, expr: ?Expression, },
};

pub const Utility = union(enum){
    Function: struct{ name: token_types.Token, params: ?Utility.Parameters, block: Statement.Block, },
    Parameters: struct{ primary: token_types.Token, secondary: ?[]token_types.Token, },
    Arguments: struct { primary: Expression, secondary: ?[]Expression, },
};
