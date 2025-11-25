const std = @import("std");
const token_types = @import("token.zig");


const Grammer = @This();

const Expression = union(enum){
    Literal: struct{ expr: token_types.Token, },
    Grouping: struct{ expr: *Expression, },
    Unary: struct{ op: token_types.Token, right: *Expression, },
    Binary: struct{ op: token_types.Token, left: *Expression, right: *Expression, },
};
