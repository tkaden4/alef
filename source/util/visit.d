module util.visit;

/* TODO add ability to visit unions based on type */

auto fail(string from="", Args...)(Args args)
{
    throw new Exception(
            "failed %s",
            from.length == 0 ? "" : "in " ~ from);
}

auto dispatchOn(alias unhandled=fail, V, T)(auto ref V visitor, auto ref T t)
in {
    static if(__traits(compiles, cast(bool)visitor)){
        assert(visitor, "cannot dispatch on null visitor");
    }
    assert(t, "cannot dispatch on null argument");
} body {

    import std.traits;
    import util;

    foreach(i, x; typeof(__traits(getOverloads, V, "visit"))){
        alias ParamType = Parameters!x[0];
        import std.stdio;
        if(typeid(t) is typeid(ParamType)){
            auto casted = t.fastCast!ParamType;
            static if(is(ReturnType!x == void)){
                visitor.visit(casted);
            }else{
                return visitor.visit(casted);
            }
        }
    }
    unhandled(t);
    assert(false);
}

auto fnVisitor(Args...)(Args args)
{
    auto visitors()
    {
        import std.traits;
        string result = "";
        foreach(i, x; Args){
            alias ArgType = Parameters!x[0];
            alias RetType = ReturnType!x;
            result ~= `
                auto visit(` ~ ArgType.stringof ~ ` t)
                {
                    static if(is(` ~ RetType.stringof ~ ` == void)){
                        args[` ~ i.stringof ~ `](t);
                    }else{
                        return args[` ~ i.stringof ~ `](t);
                    }
                }
            `;
        }
        return result;
    }
    struct FnVisitor {
        mixin(visitors());
    }
    return FnVisitor();
}

auto visitSwitch(T, Args...)(auto ref T t, Args args)
{
    auto visitor = fnVisitor(args);
    static if(is(typeof(visitor.dispatchOn(t)) == void)){
        visitor.dispatchOn(t);
    }else{
        return visitor.dispatchOn(t);
    }
}

unittest
{
    auto fnVis =
        fnVisitor(
            (int k) => k,
            (double x) => 0
        );
    assert(fnVis.dispatchOn(8) == 8, "8 == 8");
    assert(fnVis.dispatchOn(8.0) == 0, "8.0 == 0");

    auto fnVis2 =
        fnVisitor(
            (int n) => 1,
            (string a) => 0
        );
    assert(fnVis2.dispatchOn("") == 0, "\"\" == 0");
    assert(fnVis2.dispatchOn(8) == 1, "int == 1");

    import std.exception;

    assert(8.visitSwitch((int k) => 0) == 0, "8 == 0");
    assert("".visitSwitch((int k) => 0).ifThrown(true), "throws");
}
