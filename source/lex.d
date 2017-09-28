module lex;

import std.traits;
import std.range;
import std.algorithm;
import std.stdio;

import util;
import flex;

/* Lexer module */

template isLexable(R)
{
    enum isLexable = isInputRange!R && isSomeChar!(ElementType!R);
}

struct Location {
    string file;
    uint line;
    uint column;

    @disable this();
    this(in string file, uint line, uint column)
    {
        this.file = file;
        this.line = line;
        this.column = column;
    }

    mixin fancyToString;
}

struct Token {
    enum Type : uint {
        STRING,
        INTEGER,
        DOUBLE,
        CHAR,
        EOS
    };

    Type type;
    string lexeme;
    Location location;

    @disable this();
    this(Type type, in string lexeme, in Location location)
    {
        this.type = type;
        this.location = location;
        this.lexeme = lexeme;
    }

    mixin fancyToString;
}

auto isConstant(in Token tok) @property
{
    switch(tok.type) with(Token.Type){
    case STRING:
    case INTEGER:
    case DOUBLE:
    case CHAR:
        return true;
    default:
        return false;
    }
}

auto ref lex(R)(auto ref R range)
    if(isLexable!R)
{
    /* Input range of tokens */
    static struct LexRange {
        private R range;

        this(in R range)
        {
            this.range = range;
        }

        private auto lexNext()
        {
            return Token(Token.Type.EOS, "EOS", Location("null", 0, 0));
        }

        void popFront()
        {
            this.range.popFront;
        }

        auto ref front() @property
        {
            import std.conv;
            return Token(Token.Type.EOS, this.range.front.to!string, Location("none", 0, 0));
        }

        auto empty() const @property
        {
            return this.range.empty;
        }
    }

    return LexRange(range);
}
