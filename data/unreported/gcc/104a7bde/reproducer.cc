void foo ()
{
  i;
  auto f = [=] { contract_assert (i > 0); };
}
