module util;

import std.conv;
import std.range;
import std.algorithm;
import std.traits;
import std.stdio;

public import util.LookaheadRange;
public import util.visit;

/* Utility Functions */

/* evaluate pred with the front of range and the value as arguments,
 * throwing an instance of E on failure, and popping and returning the
 * front of the range on success */
public auto matchOn(
        alias pred = (x, y) => x == y,
        Err = Exception,
        R,
        E)(auto ref R range, auto ref E elem)
    if(isInputRange!R)
{
    import std.string;
    enforce(!range.empty, "empty range, could not match");
    if(!pred(range.front, elem)){
        throw new Err("mismatch: expected %s, got %s".format(elem, range.front));
    }
    return range.popNext;
}


/* pops a value and returns it */
auto ref popNext(R)(auto ref R range)
    if(isInputRange!R)
{
    import std.exception;
    import std.stdio;
    enforce(!range.empty, "unable to popNext from empy range");
    auto front = range.front;
    range.popFront;
    return front;
}

auto fastCast(T, F)(auto ref F f)
//    if(is(F == class) && is(T == class))
{
    return *cast(T*)&f;
}

/* Creates Json-like strings */
mixin template fancyToString(alias conv = to!string)
{
    import std.string;
    import std.range;
    import std.algorithm;
    import std.traits;
    
    alias thisType = Unqual!(typeof(this));

    enum toStringBody = `
        {
            auto s = Unqual!(typeof(this)).stringof ~ " { ";
            alias fields = FieldNameTuple!(typeof(this));
            foreach(field; fields){
                alias valueType = Unqual!(typeof(mixin("this." ~ field)));
                auto fieldVal = mixin(field);

                static if(is(valueType == string)){
                    s ~= "%s: \"%s\"".format(field, conv(fieldVal));
                }else{
                    s ~= "%s: %s".format(field, conv(fieldVal));
                }
                s ~= " ";
            }
            s ~= "}";
            return s;
        }
    `;

    static if(is(thisType == class)){
        mixin("override string toString() const" ~ toStringBody);
    }else{
        mixin("string toString() const" ~ toStringBody);
    }
};

/* Create a struct-like class 
 * this entails a static constructor
 * (not requiring new), as well as 
 * a constructor that initializes
 * all members */
mixin template classStruct()
{
    import std.meta;
    import std.traits;

    alias ThisType = typeof(this);

    alias FieldTypes = Fields!ThisType;
    alias FieldNames = FieldNameTuple!ThisType;

    this(inout(FieldTypes) args)
    {
        foreach(i, x; FieldNames){
            mixin("this." ~ x ~ " = args[i];");
        }
    }

    mixin fancyToString;
    mixin simpleConstructor;
}

/* Dont need a 'new' to create a class 
 * e.g struct allocation, but for classes */
mixin template simpleConstructor()
{
    import std.algorithm;

    alias ThisType = typeof(this);
    static auto opCall(Args...)(in inout(Args) args)
    {
        return new ThisType(args);
    }
};
