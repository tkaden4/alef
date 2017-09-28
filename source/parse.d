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

alias TokenRange = LookaheadRange!(typeof("".lex));

template templateIs(alias A, alias B)
{
    enum templateIs = is(A == B);
}

template isTokenRange(R)
{
    enum isTokenRange = isInputRange!R && is(ElementType!R == Token);
}

/* allows for backtracking */
/* TODO speed up backtracking through memoization */
struct ResettableRange(R)
    if(isLookaheadRange!R)
{
    private R range = void;
    private size_t currentPosition = 0;
    private size_t savedPosition = 0;

    @disable this();
    this(R range)
    {
        this.range = range;
    }

    /* for InputRange */
    void popFront()
    {
        ++this.currentPosition;
    }

    auto front() @property
    {
        return this.lookahead;
    }
    
    auto empty() @property
    {
        if(this.range.empty){
            return true;
        }else{
            try {
                this.range.lookahead(this.currentPosition);
            } catch(Exception e) {
                return true;
            }
        }
        return false;
    }

    /* For LookaheadRange */

    auto lookahead(size_t n=0) @property
    {
        return this.range.lookahead(this.currentPosition + n);
    }

    /* Reset functionality */

    void reset()
    {
        this.currentPosition = this.savedPosition;
    }
}

unittest
{
    alias asReset = resettableRange;
    enum emptyRange = asReset("");
    enum spaceRange = asReset(" ");

    assert(emptyRange.empty, "range is not empty");
    assert(!spaceRange.empty, "range is empty");

    /* Testing for failure */
    import std.exception;
    assert(emptyRange.lookahead.ifThrown(true), "should throw");
    assert(spaceRange.lookahead.ifThrown(false), "should not throw");
    
    /* Reset testing */
    enum sampleRange = asReset("abcdefghijklmnopqrstuvwxyz");
    with(sampleRange){
        popFront;
        assert(front == 'b', "front not correct");
        assert(lookahead(1) == 'c', "second from front not correct");
    }

    with(sampleRange){
        assert(front == 'a', "front not correct");
        popFront;
        assert(front == 'b', "second from front not correct");
        reset;
        assert(front == 'a', "front after resetting not correct");
    }
}

auto resettableRange(R)(auto ref R range)
    if(isInputRange!R)
{
    static if(isLookaheadRange!R){
        return ResettableRange!R(range);
    }else{
        return range.lookaheadRange.resettableRange;
    }
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
