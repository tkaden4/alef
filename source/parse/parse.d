module parse;

import std.range;
import std.exception;
import std.string;
import std.typecons;
import std.meta;
import std.traits;
import std.variant;

import lex : lex, Token;
import util;

/* TODO
   1. Add error information
   2. Track line numbers
   3. Optimize through richer metadata about parsing rules
   4. Ignored rules, debugging info (lookahead-k, time, etc.)
 */

final class ParseException : Exception { mixin basicExceptionCtors; }

template isTokenRange(R)
{
    enum isTokenRange = isInputRange!R && is(ElementType!R == Token);
}

/* XXX too specific generalize over the range */
alias TokenRange = ResetRange!(LookaheadRange!(typeof("".lex)));

/* some helpful aliases */
alias parseAtLeastN(size_t n, alias rule) = parseAnd!(parseN!(n, rule), parseAnyAmount!rule);
alias parseOptional(alias rule) = parseOr!(rule, nothingRule);

auto parse(R)(auto ref R range)
    if(isInputRange!R)
{
    auto parseRange = range.resetRange;
    return parseRange.parseProgram;
}

/* XXX too specific */
auto parseToken(Token.Type type)(ref TokenRange range)
{
    enforceEx!ParseException(
        range.front.type == type,
        "expected token of type %s, but got %s :: %s"
            .format(type, range.front.lexeme, range.front.type)
    );
    return range.popNext.lexeme;
}

/* TODO determine embiguity */
auto parseOr(Args...)(ref TokenRange range)
{
    auto result = Algebraic!(staticMap!(ReturnType, Args))();
    foreach(x; Args){
        try {
            result = x(range);
        } catch(ParseException e) {
            range.reset;
        }
    }
    enforceEx!ParseException(result.hasValue, "unable to determine result in parseOr");
    return result;
}

unittest
{
    auto x = "9 9".lex.resetRange;
    auto res = x.parseOr!(
        parseToken!(Token.Type.STRING),
        parseToken!(Token.Type.INTEGER),
        parseToken!(Token.Type.EOS));
    assert(res.get!(2) == "9", "invalid result");
}

auto parseAnd(Args...)(ref TokenRange range)
{
    auto result = Tuple!(staticMap!(ReturnType, Args))();
    foreach(i, x; Args){
        result[i] = x(range);
    }
    return result;
}


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
            debug {
                import std.stdio;
                "optional was null".writeln;
            }
            break;
        }
    }
    return results;
}

/* represents epsilon in formal parsing, and always succeeds */
auto nothingRule(ref TokenRange range){ return tuple(); }

auto parseProgram(ref TokenRange range)
{
    return range.parseAnyAmount!parseExpression;
}

auto parseExpression(ref TokenRange range)
{
    return tuple("string");
}
