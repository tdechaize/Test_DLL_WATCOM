@echo off
set PATHINIT=%PATH%
set PATH=C:\WATCOM\binnt;%PATH%
REM 	Compile only main core of DLL
echo.   **************        Compile only main core of DLL      ****************
wcc386 -q -bd dllsamp -i=C:\WATCOM\h\nt -i=C:\WATCOM\h
REM 	Link main core of DLL with directive file dllsamp.lnk
echo.   *******  Link main core of DLL with directive file dllsamp.lnk  *********
wlink @dllsamp.lnk
REM 	Mandatory, because directives of precedent link don't generate this library.
echo.   **************         Generate lib file from DLL        ****************
wlib -q -n dllsamp +dllsamp.dll
REM 	Dump export functions of DLL 
echo.   **************         Dump export functions of DLL      ****************
wdump -i dllsamp.dll
REM 	Compile and link test program of DLL
echo.   **************   Compile and link test program of DLL    ****************
wcl386 -q -bm -l=nt dlltest dllsamp.lib -i=C:\WATCOM\h\nt -i=C:\WATCOM\h
REM 	Execute test program of DLL (version 32 bits)
echo.   *********   Execute test program of DLL (version 32 bits)  **************
dlltest
set PATH=%PATHINIT%