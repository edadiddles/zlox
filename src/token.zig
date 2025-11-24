const std = @import("std");

pub const TokenType = enum{
    LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
    COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,

    BANG, BANG_EQUAL,
    EQUAL, EQUAL_EQUAL,
    GREATER, GREATER_EQUAL,
    LESS, LESS_EQUAL,

    IDENTIFIER, STRING, NUMBER,

    AND, CLASS, ELSE, FUN, FOR, IF, NIL, OR, PRINT,
    RETURN, SUPER, THIS, TRUE, FALSE, VAR, WHILE,

    EOF,
};

pub const Token = struct{
    type: TokenType,
    lexeme: []const u8,
    line: usize,

    pub fn init(token_type: TokenType, line: usize, lexeme: ?[]u8) Token {
        return Token{
            .type = token_type,
            .lexeme = lexeme orelse "",
            .line = line,
        };
    }
};


pub const Keywords = struct{
    keyword_map: std.StringHashMap(TokenType),

    pub fn init(allocator: std.mem.Allocator) !Keywords {
        var keyword_map: std.StringHashMap(TokenType) = .init(allocator);
        try keyword_map.put("and", TokenType.AND);
        try keyword_map.put("class", TokenType.CLASS);
        try keyword_map.put("fun", TokenType.FUN);
        try keyword_map.put("for", TokenType.FOR);
        try keyword_map.put("if", TokenType.IF);
        try keyword_map.put("nil", TokenType.NIL);
        try keyword_map.put("or", TokenType.OR);
        try keyword_map.put("print", TokenType.PRINT);
        try keyword_map.put("return", TokenType.RETURN);
        try keyword_map.put("super", TokenType.SUPER);
        try keyword_map.put("this", TokenType.THIS);
        try keyword_map.put("true", TokenType.TRUE);
        try keyword_map.put("false", TokenType.FALSE);
        try keyword_map.put("var", TokenType.VAR);
        try keyword_map.put("while", TokenType.WHILE);
        return Keywords{
            .keyword_map = keyword_map,
        };
    }

    pub fn deinit(self: Keywords) void {
        self.keyword_map.deinit();
    }

    pub fn get_keyword_map(self: Keywords) std.StringHashMap(TokenType) { 
        return self.keyword_map;
    }
};

