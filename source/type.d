module type;

interface ASTType {
static:
    __gshared AUTO = new ASTAutoType;
}

enum ASTPrimitiveType : ASTType {
    UNIT = new ASTUnitType,
    LONG = new ASTUnitType,
    CHAR = new ASTUnitType,
    STRING = new ASTUnitType
}

final class ASTUnitType : ASTType {}

final class ASTProcType : ASTType {
    ASTType retType;
    ASTType[] parameterTypes;
}

alias ASTAutoType = ASTUnitType;

/* primitive type getters */

auto astType(T: long)()
{
    return ASTPrimitiveType.LONG;
}

auto astType(T: char)()
{
    return ASTPrimitiveType.CHAR;
}

auto astType(T: string)()
{
    return ASTPrimitiveType.STRING;
}

auto astType(T: void)()
{
    return ASTPrimitiveType.UNIT;
}
