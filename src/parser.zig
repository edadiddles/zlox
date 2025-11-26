const std = @import("std");
const token_types = @import("token.zig");

const Parser = @This();

tokens: []const token_types.Token,
pos: usize,
read_pos: usize,


fn init(tokens: []const token_types.Token) Parser {
    return .{
        .tokens = tokens,
        .pos = 0,
        .read_pos = 0,
    };
}

fn parse(self: *Parser) !void {
    while(!self.at_eof()) {
        const token = self.read_token();
        std.debug.print("Reading Token: {}\n", .{ token });
    }
}

fn at_eof(self: Parser) bool {
    return self.tokens[self.read_pos].type == token_types.TokenType.EOF;
}

fn read_token(self: *Parser) token_types.Token {
    const token = self.tokens[self.read_pos];
    self.read_pos += 1;
    return token;
}

fn peek(self: Parser, n: usize) token_types.Token {
    return self.tokens[self.read_pos+n];
}

test parse {
    const tokens = [_]token_types.Token{
        token_types.Token{ .type = .STRING, .lexeme = "hello world", .line = 0 },
        token_types.Token{ .type = .VAR, .lexeme = "var", .line = 0 },
        token_types.Token{ .type = .SLASH, .lexeme = "/", .line = 0 },
        token_types.Token{ .type = .IDENTIFIER, .lexeme = "iati", .line = 0 },
        token_types.Token{ .type = .NUMBER, .lexeme = "1.23", .line = 1 },
        token_types.Token{ .type = .NUMBER, .lexeme = "1", .line = 1 },
        token_types.Token{ .type = .NUMBER, .lexeme = "3212123.121", .line = 1 },
        token_types.Token{ .type = .DOT, .lexeme = ".", .line = 1 },
        token_types.Token{ .type = .NUMBER, .lexeme = "123", .line = 1 },
        token_types.Token{ .type = .EOF, .lexeme = "eof", .line = 1 },
    };
    
    var parser: Parser = .init(&tokens);

    try parser.parse();

}
