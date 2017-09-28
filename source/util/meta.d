module util.meta;

template templateIs(alias A, alias B)
{
    enum templateIs = is(A == B);
}
