module util.ResetRange;

import std.range;

import util.LookaheadRange;

/* function for creating ResetRanges */
auto resetRange(R)(auto ref R range)
    if(isInputRange!R)
{
    static if(isLookaheadRange!R){
        return ResetRange!R(range);
    }else{
        return range.lookaheadRange.resetRange;
    }
}

/* allows for backtracking */
/* TODO speed up backtracking through memoization */
struct ResetRange(R)
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
    alias asReset = resetRange;
    enum emptyRange = asReset("");
    enum spaceRange = asReset(" ");

    assert(emptyRange.empty, "range is not empty");
    assert(!spaceRange.empty, "range is empty");

    /* Testing for failure */
    import std.exception;
    assert(emptyRange.lookahead.ifThrown(true), "should throw");
    assert(spaceRange.lookahead.ifThrown(false), "should not throw");

    with(asReset("a")){
        popFront;
        assert(empty, "range fakes emptyness");
        reset;
        assert(!empty, "range fakes fullness");
    }
    
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

