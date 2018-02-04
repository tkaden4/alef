import std.stdio;
import std.range;
import std.algorithm;
import std.string;
import std.traits;
import std.getopt;
import std.file;

import util;

enum usage = "Usage: alefc [-o <out>] <*.al>...";

auto compile(R)(auto ref R files)
    if(isInputRange!R && isSomeString!(ElementType!R))
{
    foreach(x; files){
        x.compile;
    }
}

auto compile(R)(auto ref R file)
    if(isSomeString!R)
{
    debug "compiling %s".writefln(file);
    
    import lex;
    import parse;
    import util.LookaheadRange;

    file
        .readText
        .lex
        .parse
        .writeln;

    debug "finished compiling".writeln;
}

int main(string[] args)
{
    auto outfile = "out.c";
    auto include = ".";

    /* parse arguments */
    {
        auto helpInfo = getopt(
            args,
            std.getopt.config.caseSensitive,
            "include|I", &include,
            "out|o", &outfile
        );

        if(helpInfo.helpWanted){
            defaultGetoptPrinter(usage, helpInfo.options);
        }
    }

    /* expand relative paths */
    {
        import std.path;
        include = absolutePath(include);
        outfile = absolutePath(outfile);
    }

    if(outfile.exists){
        "output file %s already exists".writefln(outfile);
    }

    debug {
        writefln("include dir: " ~ include);
        writefln("output file: " ~ outfile);
    }

    args.drop(1).compile;

    return 0;
}
