module util.meta;

template templateIs(alias A, alias B)
{
    enum templateIs = is(A == B);
}

template expandArray(string array, size_t n)
{
    static if(n == 1){
        enum expandArray = array ~ "[" ~ n.stringof  ~ " - 1]";
    }else{
        enum expandArray = expandArray!(array, n - 1) ~ "," ~ array ~ "[" ~ n.stringof ~ " - 1]";
    }
}

