module parse;

import std.range;
import std.exception; import std.string;
import std.typecons;
import std.meta;
import std.traits;
import std.variant;

import lex : lex, Token;
import util;

alias TokenRange = LookaheadRange!(typeof("".lex));

template isTokenRange(R)
{
    enum isTokenRange = isInputRange!R && is(ElementType!R == Token);
}

auto parse(R)(auto ref R inputRange)
    if(isInputRange!R)
{
    auto range = inputRange.lookaheadRange;
    return range.parseProgram;
}

auto parseToken(Token.Type type)(ref TokenRange range)
{
    enforce(
        range.front.type == type,
        "expected %s, but got %s".format(type, range.front.type)
    );
    return range.popNext.lexeme;
}

auto parseOr(Args...)(ref TokenRange range)
{
    auto result = Algebraic!(staticMap!(ReturnType, Args))();
    return result;
}

auto parseAnd(Args...)(ref TokenRange range)
{
    auto result = Tuple!(staticMap!(ReturnType, Args))();
    foreach(i, x; Args){
        result[i] = x(range);
    }
    return result;
}

alias parseAtLeastN(size_t n, alias rule) = parseAnd!(parseN!(n, rule), parseAnyAmount!rule);
alias parseOptional(alias rule) = parseOr!(rule, nothingRule);

auto parseN(size_t n, alias rule)(ref TokenRange range)
{
    ReturnType!rule[] results;
    results.reserve(n);
    foreach(_; 0 .. n){
        results ~= rule(range);
    }
    return results;
}

auto parseAnyAmount(alias rule)(ref TokenRange range)
{
    ReturnType!rule[] results;
    for(;;){
        auto result = range.parseOptional!rule; 
        try {
            results ~= result.get!0;
        } catch(VariantException e) {
            break;
        }
    }
    return results;
}

auto nothingRule(ref TokenRange range)
{
    return tuple();
}

auto parseProgram(ref TokenRange range)
{
    return range.parseAnyAmount!parseExpression;
}

auto parseExpression(ref TokenRange range)
{
    return "expression";
}
