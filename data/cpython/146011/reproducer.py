import decimal

ctx = decimal.Context(prec=7)
mapping = ctx.flags
del ctx
print(mapping)
