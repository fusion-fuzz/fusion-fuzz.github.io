con1 <- textConnection("out", "w")
cat("a", file = con1)                # incomplete line: kept in C buffer, 'out' not yet locked
con2 <- textConnection("out", "w")   # rebinds 'out'; con1's character vector is now unreferenced
gc()                                 # frees it, but con1 still points to it
close(con1)                          # outtext_close() uses the freed STRSXP
