@echo off
set PATHINIT=%PATH%
set PATH=C:\WATCOM\binnt64;%PATH%
REM 	Compile only main core of DLL
echo.   **************        Compile only main core of DLL      ****************
wcc386 -q -bd -v dllsamp -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=dllsamp64.obj
REM 	Link main core of DLL with directive file dllsamp64.lnk
echo.   ******* Link main core of DLL with directive file dllsamp64.lnk *********
wlink @dllsamp64.lnk
REM 	Mandatory, because directive of precedent link don't generate this library.
echo.   **************         Generate lib file from DLL        ****************
wlib -q -n dllsamp64 +dllsamp64.dll
REM 	Dump export functions of DLL
echo.   **************         Dump export functions of DLL      ****************
wdump -i dllsamp64.dll
REM 	Compile and link test program of DLL
echo.   **************   Compile and link test program of DLL    ****************
wcl386 -q -bm -l=nt dlltest dllsamp64.lib -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=dlltest64.exe
REM 	Execute test program of DLL (version 64 bits)
echo.   *********   Execute test program of DLL (version 64 bits)  **************
dlltest64
set PATH=%PATHINIT%