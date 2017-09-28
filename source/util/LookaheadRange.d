module util.LookaheadRange;

import std.range;
import std.algorithm;
import std.exception;

import util : popNext;

template isLookaheadRange(R)
    if(isInputRange!R)
{
    enum isLookaheadRange = __traits(hasMember, R, "lookahead");
}

/* Create a range that allows caching of arbitrary lookahead */

public auto ref lookaheadRange(R)(auto ref R range)
{
    return LookaheadRange!R(range);
}

public struct LookaheadRange(R)
    if(isInputRange!R)
{
    private ElementType!R[] cache = void;
    private R range = void;

    @disable this();

    /* range functions */

    this(ref R range)
    {
        this.range = range;
    }

    auto opIndex(size_t n)
    {
        return this.lookahead(n);
    }

    void popFront()
    {
        this.ensureCapacity;
        this.cache = this.cache[1..$];
    }

    auto front() @property
    {
        return this.lookahead;
    }

    auto empty() @property const
    {
        return this.cache.empty && this.range.empty;
    }
    
    /* Lookahead utilities */

    auto lookahead(size_t n=0)
    {
        this.ensureCapacity(n + 1);
        return this.cache[n];
    }

    private auto ensureCapacity(size_t n=1)
    {
        if(n < this.cache.length) return;
        const diff = n - this.cache.length;
        this.cache.reserve(diff);
        foreach(x; 0..diff){
            this.cache ~= this.range.popNext;
        }
    }
};
