module tree.pattern;

/* TODO Convert F to T using structural conversion */
/*
T autoConvert(T, F)(auto ref F f)
{
    return T.init;
}
*/

/* TODO pattern matching rules */

/*
template DestructureOf(alias T)
{

}

template NamedMatch(string name)
{
    import std.traits;
    auto NamedMatch(T)(auto ref T t)
        if(isAggregateType!T)
    {
        mixin("return t." ~ name ~ ";");
    }
}
*/

template isTemplate(T)
{
    enum isTemplate = __traits(isTemplate, T);
}


/* test code */
/+
static this()
{
    static struct Pair {
        size_t x;
        size_t y;
    }

    auto x = match!"(x %)"(Pair(0, 0));

    auto _matches = matches!"(%lu %lu)"(Pair(0, 0));


    auto _matches2 =
        matches!(
                AggrPat!(ValueMatch!0, ValueMatch!0)
            )(Pair(0, 0));

    auto pattern = compilePattern("(%lu, %lu)", 0, 0);

    auto _rtmatch =
        matches(
            aggregate(value(0), value(8)),
            Pair(0, 0));

    match.writeln;
}
+/
