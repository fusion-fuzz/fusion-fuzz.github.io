#define T1(XT,XK,MT,MK) \
block; \
  print *, #XT, XK, #MT, MK, out_of_range(x,mold); \
end block
#define INTMOLDS(M,XT,XK) \
  M(XT,XK,integer,1); \

#define INTXS(M1,M2) \
  M1(M2, integer, 16)
#define REALXS(M1,M2) \
INTXS(INTMOLDS, T1)
REALXS(REALMOLDS, T1)
end
