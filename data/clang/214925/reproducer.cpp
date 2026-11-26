#pragma clang module build A
module A {}
#pragma clang module contents
#pragma clang module begin A
#pragma clang module build B
module B {}
#pragma clang module endbuild
#pragma clang module import B
#pragma clang module end
#pragma clang module endbuild
#pragma clang module build B
module B {}
#pragma clang module contents
#pragma clang module begin B
#pragma clang module import A
#pragma clang module end
