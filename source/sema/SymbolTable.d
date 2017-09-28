module sema.SymbolTable;

struct Symbol(T) {
    string name;
    T value;
}

interface SymbolTable(SymType) {
    alias SymIDType = typeof(SymType.name);
    SymType *opIndex(in SymIDType id);
    void opIndexAssign(SymType symbol, in SymIDType id);
}

unittest
{
    alias MySym = Symbol!string;
    class MySymTab : SymbolTable!MySym
    {
        private MySym[string] symbols;
        private MySymTab parent;

        this(MySymTab parent=null)
        {
            this.parent = parent;
        }

        override MySym* opIndex(in string id)
        {
            if(auto found = id in this.symbols){
                return found;
            }else{
                return
                    this.parent ?
                    this.parent[id] :
                    null;
            }
        }

        override void opIndexAssign(MySym symbol, in string id)
        {
            this.symbols[id] = symbol;
        }
    }

    auto parent = new MySymTab;
    assert(parent["foo"] == null, "lookup of non-existant id");
    parent["foo"] = MySym("foo", "bar");
    assert(*parent["foo"] == MySym("foo", "bar"), "lookup of non-existant id");

    auto child = new MySymTab(parent);
    assert(child["foo"] != null, "child -> parent lookup");
    assert(child["baz"] == null, "child null lookup");
    child["baz"] = MySym("baz", "bam");
    assert(child["baz"] != null, "child non-null lookup");
    assert(parent["baz"] == null);
}
