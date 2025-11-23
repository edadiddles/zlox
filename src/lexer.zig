const std = @import("std");
const token_types = @import("token.zig");

const Scanner = @This();

buffer: []u8,
tokens: []token_types.Token,
curr_line: usize,
pos: usize,
read_pos: usize,
token_pos: usize,


pub fn init(buffer: []u8, tokens: []token_types.Token) Scanner {
    return Scanner{
        .buffer = buffer,
        .tokens = tokens,
        .curr_line = 0,
        .pos = 0,
        .read_pos = 0,
        .token_pos = 0,
    };
}

pub fn scan(self: *Scanner) void {
    while(!self.at_eof()) {
        self.pos = self.read_pos;
        switch(self.read_char()) {
            '(' => self.add_token(token_types.TokenType.LEFT_PAREN),
            ')' => self.add_token(token_types.TokenType.RIGHT_PAREN),
            '{' => self.add_token(token_types.TokenType.LEFT_BRACE),
            '}' => self.add_token(token_types.TokenType.RIGHT_BRACE),
            ',' => self.add_token(token_types.TokenType.COMMA),
            '.' => self.add_token(token_types.TokenType.DOT),
            '+' => self.add_token(token_types.TokenType.PLUS),
            '-' => self.add_token(token_types.TokenType.MINUS),
            '!' => {
                if (self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.BANG_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.BANG);
            },
            '=' => {
                if (self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.EQUAL_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.EQUAL);
            },
            '>' => {
                if (self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.GREATER_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.GREATER);
            },
            '<' => {
                if (self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.LESS_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.LESS);

            },
            else => {},
        }
    }

    self.add_eof();
    self.print();
}

fn read_char(self: *Scanner) u8 {
    const char = self.buffer[self.read_pos];
    std.debug.print("reading char: {c}\n", .{ char });
    self.read_pos += 1;
    return char;
}

fn peek(self: Scanner, n: usize) u8 {
    if(self.at_eof()) return 0;
    return self.buffer[self.read_pos + n];
}

fn add_token(self: *Scanner, token_type: token_types.TokenType) void {
    std.debug.print("adding token: {s}\n", .{ self.buffer[self.pos..self.read_pos] });
    self.tokens[self.token_pos] = token_types.Token{
        .type = token_type,
        .line = self.curr_line,
        .lexeme = self.buffer[self.pos..self.read_pos],
    };
    self.token_pos += 1;
}

fn add_eof(self: *Scanner) void {
    self.tokens[self.token_pos] = token_types.Token{
        .type = token_types.TokenType.EOF,
        .line = self.curr_line,
        .lexeme = "eof",
    };
}

fn at_eof(self: Scanner) bool {
    return self.read_pos >= self.buffer.len;
}

fn print(self: Scanner) void {
    for (self.tokens) |token| {
        std.debug.print("Token: ({s},{d}) -- line: {d}\n", .{ token.lexeme, token.type, token.line });
        if (token.type == token_types.TokenType.EOF) {
            break;
        }
    }
}


test "parse tokens" {
    const allocator = std.testing.allocator;
    const tokens = try allocator.alloc(token_types.Token, 64);
    defer allocator.free(tokens);

    const buffer = try allocator.alloc(u8, 18);
    defer allocator.free(buffer);

    @memcpy(buffer[0..], "(){},.+-<==!==><=>"[0..]);
    var scanner = Scanner.init(buffer, tokens);
    scanner.scan();
}
