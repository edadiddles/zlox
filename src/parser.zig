const std = @import("std");
const token_types = @import("tokens.zig");

const Parser = @This();

tokens: []token_types.Token,
pos: usize,
read_pos: usize,

