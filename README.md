# Test_DLL_WATCOM
Generate DLL and test (multiples tests)

Initials objectives : code and test DLL in which entry point is used, multiple functions defined, and call of these functions are "natural" : only by the name 
of function (with not decorations : "_" before or after, or "@nn" in suffix of the name of function).

Results : all tests DLL are good with this compiler, but, same with 64 bits version of it, the result of executable/dll is always in 32 bits... 
        Shame, when this compiler will can generate 64 bits version of executable/dll ? Another concurrent, can generate it ...
