%option noyywrap
%option reentrant

%{
#include<stdio.h>

enum token_e {
    EOS = 0
};

%}

%%
[_a-zA-Z][_a-zA-Z0-9]* { return 0; }
%%
