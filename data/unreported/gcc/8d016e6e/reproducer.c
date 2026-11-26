int cnt;
void f (double *s, double *M)
{
  for (int i = 0; i < 4; i++)
    for (int j = 0; j < 4; j++)
      for (int l = 0; l < 4; l++)
        for (int m = 0; m < 4; m++)
          {
            double val = 0;
            for (int k = 0; cnt; k++)
              val += s[k];
            M[i + 4 * (j + 4 * (l + 4 * m))] = val;
          }
}
