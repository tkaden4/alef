module flex;

/* Wrapper for the parser generated from the grammar
   in lexer/
 */
/* TODO add scanning of ranges */

alias yyscan_t = void*;

class Flex {
    import std.stdio;
    import std.exception;

    private yyscan_t scanner;

    this()
    {
        enforce(!yylex_init(&this.scanner));
    }

    auto lex()
    {
        yylex(this.scanner);
        return this.text;
    }

    string text()
    {
        import std.string;
        import std.conv;
        return yyget_text(this.scanner).fromStringz.to!string;
    }

    void inFile(File* file) @property
    {
        this.inFile = *file;
    }

    void inFile(ref File file) @property
    {
        yyset_in(file.getFP, this.scanner);
    }

    FILE *inFile() @property
    {
        return yyget_in(this.scanner);
    }

    void outFile(ref File file) @property
    {
        yyset_out(file.getFP, this.scanner);
    }

    FILE *outFile() @property
    {
        return yyget_out(this.scanner);
    }

    int length() @property
    {
        return yyget_leng(this.scanner);
    }

    int lineno() @property
    {
        return yyget_lineno(this.scanner);
    }

    void lineno(int line) @property
    {
        yyset_lineno(line, this.scanner);
    }

    int debugFlag() @property
    {
        return yyget_debug(this.scanner);
    }

    void debugFlag(int flag) @property
    {
        yyset_debug(flag, this.scanner);
    }

    auto destroy()
    {
        enforce(!yylex_destroy(this.scanner));
        this.scanner = null;
    }

    ~this()
    {
        if(this.scanner != null){
            this.destroy();
        }
    }
}

extern(C):
int yylex_init(yyscan_t*);
int yylex(yyscan_t);
int yylex_destroy(yyscan_t);

import core.stdc.stdio;
/* getters */
char* yyget_text(yyscan_t);
int yyget_leng(yyscan_t);
FILE* yyget_in(yyscan_t);
FILE* yyget_out(yyscan_t);
int yyget_lineno(yyscan_t);
int yyget_debug(yyscan_t);
void function(int, const(char)*) yyget_extra(yyscan_t);

/* setters */
void yyset_debug(int, yyscan_t);
void yyset_in(FILE*, yyscan_t);
void yyset_out(FILE*, yyscan_t);
void yyset_lineno(int, yyscan_t);
void yyset_extra(void function(int, const(char)*), yyscan_t);
