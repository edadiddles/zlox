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

pub fn scan(self: *Scanner) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const keywords = try token_types.Keywords.init(gpa.allocator());
    while(!self.at_eof()) {
        self.pos = self.read_pos;
        const char = self.read_char();
        switch(char) {
            '(' => self.add_token(token_types.TokenType.LEFT_PAREN),
            ')' => self.add_token(token_types.TokenType.RIGHT_PAREN),
            '{' => self.add_token(token_types.TokenType.LEFT_BRACE),
            '}' => self.add_token(token_types.TokenType.RIGHT_BRACE),
            ',' => self.add_token(token_types.TokenType.COMMA),
            '.' => self.add_token(token_types.TokenType.DOT),
            '+' => self.add_token(token_types.TokenType.PLUS),
            '-' => self.add_token(token_types.TokenType.MINUS),
            '*' => self.add_token(token_types.TokenType.STAR),
            ';' => self.add_token(token_types.TokenType.SEMICOLON),
            '/' => {
                if (self.peek(0) != '/') {
                    self.add_token(token_types.TokenType.SLASH);
                    continue;
                }

                while(self.peek(0) != '\n' and !self.at_eof()) {
                    _ = self.read_char();
                }
            },
            '!' => {
                if(self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.BANG_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.BANG);
            },
            '=' => {
                if(self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.EQUAL_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.EQUAL);
            },
            '>' => {
                if(self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.GREATER_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.GREATER);
            },
            '<' => {
                if(self.peek(0) == '=') {
                    _ = self.read_char();
                    self.add_token(token_types.TokenType.LESS_EQUAL);
                    continue;
                }

                self.add_token(token_types.TokenType.LESS);

            },
            '"' => self.string(),
            ' ', '\r', '\t' => continue,
            '\n' => self.curr_line += 1,
            else => {
                if(self.is_alpha(char)) {
                    self.identifier(keywords);
                    continue;
                } else if(self.is_number(char)) {
                    self.number();
                    continue;
                }
            },
        }
    }

    self.add_eof();
    self.print();
}

fn read_char(self: *Scanner) u8 {
    const char = self.buffer[self.read_pos];
    self.read_pos += 1;
    return char;
}

fn peek(self: Scanner, n: usize) u8 {
    if(self.at_eof()) return 0;
    return self.buffer[self.read_pos + n];
}

fn is_alpha(_: Scanner, char: u8) bool {
    return ('a' <= char and char <= 'z') or ('A' <= char and char <= 'Z') or char == '_';
}

fn is_number(_: Scanner, char: u8) bool {
    return '0' <= char and char <= '9';
}

fn is_alphanumeric(self: Scanner, char: u8) bool {
    return self.is_alpha(char) and self.is_number(char);
}

fn is_whitespace(self: Scanner) bool {
    return self.buffer[self.read_pos] == ' ' or self.buffer[self.read_pos] == '\n';
}

fn identifier(self: *Scanner, keywords: token_types.Keywords) void {
    while(!self.at_eof()) {
        const next_char = self.peek(0);
        if(!(self.is_alpha(next_char) or self.is_number(next_char))) {
            break;
        }
        _ = self.read_char();
    }

    const token_type = keywords.get_keyword_map().get(self.buffer[self.pos..self.read_pos]) orelse token_types.TokenType.IDENTIFIER;
    self.add_token(token_type);
}

fn string(self: *Scanner) void {
    while(!self.at_eof()) {
        if(self.read_char() == '"') {
            break;
        }
    }
    self.add_token(token_types.TokenType.STRING);
}

fn number(self: *Scanner) void {
    var has_dot = false;
    while(!self.at_eof()) {
        const next_char = self.peek(0);
        if(!(self.is_number(next_char) or next_char == '.')) {
            break;
        } else if(next_char == '.') {
            if(has_dot) break;
            has_dot = true;
        }
        _ = self.read_char();
    }
    self.add_token(token_types.TokenType.NUMBER);
}

fn add_token(self: *Scanner, token_type: token_types.TokenType) void {
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
        if(token.type == token_types.TokenType.EOF) {
            break;
        }
    }
}


test "parse tokens" {
    const allocator = std.testing.allocator;
    const tokens = try allocator.alloc(token_types.Token, 64);
    defer allocator.free(tokens);

    const buffer = try allocator.alloc(u8, 51);
    defer allocator.free(buffer);

    @memcpy(buffer[0..], "\"hello world\" var/iati// or \n1.23 1 3212123.121.123"[0..]);
    var scanner = Scanner.init(buffer, tokens);
    try scanner.scan();
}
