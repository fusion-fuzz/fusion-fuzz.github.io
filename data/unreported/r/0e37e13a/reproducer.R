e <- new.env()
makeActiveBinding("a", function() { assign("b", 1, envir = e); 1 }, e)
x <- as.list(e)
str(x)
