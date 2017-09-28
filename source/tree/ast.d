module tree.ast;

import tree.type;

struct SourceLocation {
    string file;
    size_t line;
    size_t column;
}

interface ASTNode {}

interface ASTExpression : ASTNode {}
/* XXX ASTStatement not used */
abstract class ASTStatement : ASTExpression {}
abstract class ASTDeclaration : ASTStatement {}

final class ASTProgram : ASTNode {
    ASTNode[] topLevel;
}

/* Declarations */

final class ASTVarDecl : ASTDeclaration {
    SourceLocation location;
    string name;
    ASTType type;
    ASTExpression initExpression;
}

final class ASTProcDecl : ASTDeclaration {
    SourceLocation location;
    string name;
    ASTParameter[] parameters;
    ASTType returnType;
    ASTExpression bodyExpression;
}

final class ASTModuleIimport : ASTDeclaration {
    SourceLocation location;
    string[] path;
}

/* Expressions */

final class ASTPrimitive(T) : ASTExpression {
    SourceLocation location;
    static if(!is(T == void)){
        T value;
    }

    ASTType type() @property
    {
        return astType!T;
    }
}

alias ASTUnit = ASTPrimitive!void;
alias ASTInteger = ASTPrimitive!long;
alias ASTChar = ASTPrimitive!char;
alias ASTString = ASTPrimitive!string;

enum ASTBinaryOpType {
    ADD = "+",
    SUB = "-",
    MUL = "*",
    DIV = "/",
}

final class ASTBinaryOp : ASTExpression {
    SourceLocation location;
    ASTBinaryOpType opType;
    ASTExpression leftExpression;
    ASTExpression rightExpression;
}

enum ASTUnaryOpType {
    NEG = "-",
    POS = "+",
    INV = "~",
}

final class ASTUnaryOp : ASTExpression {
    SourceLocation location;
    ASTUnaryOpType opType;
    ASTExpression unaryExpression;
}

final class ASTProcCall : ASTExpression {
    SourceLocation location;
    ASTExpression callExpression;
    ASTArgument[] arguments;
}

/* Misc */

struct Parameter(TT) {
    string name;
    TT type;
}

alias ASTParameter = Parameter!ASTType;
alias ASTArgument = ASTExpression;
