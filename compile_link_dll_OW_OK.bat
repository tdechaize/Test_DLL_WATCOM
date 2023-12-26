@echo off
REM
REM   	Script de génération de la DLL dll_core.dll et des programmee de test : "testdll_implicit.exe" (chargement implicite de la DLL),
REM 	"testdll_explicit.exe" (chargement explicite de la DLL), et enfin du script de test écrit en python.
REM		Ce fichier de commande est paramètrable avec deux paraamètres : 
REM			a) le premier paramètre permet de choisir la compilation et le linkage des programmes en une seule passe
REM 			soit la compilation et le linkage en deux passes successives : compilation séparée puis linkage,
REM 		b) le deuxième paramètre définit soit une compilation et un linkage en mode 32 bits, soit en mode 64 bits
REM 	 		pour les compilateurs qui le supportent.
REM     Le premier paramètre peut prendre les valeurs suivantes :
REM 		ONE (or unknown value, because only second value of this parameter is tested during execution) ou TWO.
REM     Et le deuxième paramètre peut prendre les valeurs suivantes :
REM 		32, 64 ou  ALL si vous souhaitez lancer les deux générations, 32 bits et 64 bits.
REM
REM 	Author : 						Thierry DECHAIZE
REM		Date creation/modification : 	07/12/2023
REM 	Reason of modifications : 	n° 1 - wcl386 don't work first time, because I omit option "-l=nt_dll", just option "-bd" positioned. 
REM 										I think it's suffisant, but not !!! OKAY, OKAY, shame on me !!!
REM 	 							n° 2 - En enlevant l'option "impfile=dll_core[64].def" lors de l'édition des liens, je m'aperçois que 
REM 										la librairie statique est correctement générée. Youpie ! Je supprime la constitution de cette
REM 										librarie sous forme explicite et la remet dans l'edition des liens de la DLL. Bug ?
REM 	 							n° 3 - Add "-ecc" for all generations to test dll with python's script successfully, same with "int" operations. 
REM 										Generalization of "__cdecl" call, because default call ("__watcall") is not understand by extern tool like python script.
REM 										Last question in wait : why call of python script is successfull on "double" operations, same with "__watcall" generation ?
REM 	Version number :				1.1.3	          	(version majeure . version mineure . patch level)

echo. Lancement du batch de generation d'une DLL et deux tests de celle-ci avec Open Watcom 32 bits ou 64 bits
REM     Affichage du nom du système d'exploitation Windows :              	Microsoft Windows 11 Famille ... (par exemple)
REM 	Affichage de la version du système Windows :              			10.0.22621 (par exemple)
REM 	Affichage de l'architecture du système Windows : 					64-bit (par exemple)
echo. *********  Quelques caracteristiques du systeme hebergeant l'environnement de developpement.   ***********
WMIC OS GET Name
WMIC OS GET Version
WMIC OS GET OSArchitecture

REM 	Save of initial PATH on PATHINIT variable
set PATHINIT=%PATH%
echo. **********      Pour cette generation le premier parametre vaut "%1" et le deuxieme "%2".     ************* 
IF "%2" == "32" ( 
   call :complink32 %1
) ELSE (
   IF "%2" == "64" (
      call :complink64 %1
   ) ELSE (
      call :complink32 %1
	  call :complink64 %1
	)  
)

goto FIN

:complink32
echo. ******************            Compilation de la DLL en mode 32 bits        *******************
REM      Mandatory, add to PATH the binary directory of compiler OW 32 bits. You can adapt this directory at your personal software environment.
set PATH=C:\WATCOM\binnt;%PATH%
set "PAR1=%~1"
if "%PAR1%" == "TWO" (
REM     Options used by Open Watcom compiler 32 bits
REM 		-q       					Set to quiet mode
REM 		-bd       					Set option to build DLL 
REM 		-d0 						No debugging information
REM 		-ecc						Set calling conv. to __cdecl (Mandatory, if you want test DLL with Python !!! If not, default is __watcall, and Python don't call "int" operations)
REM 		-v 							Option to generate def file (like "option impfile=dll_core.def" ?!?!? but without suppression of generation of lib file)
REM 		-dxxxxx	 					Define variable xxxxxx used by precompiler
REM 		-ixxxxxx					Define search path to include file
REM 		-fo=xxxxx 					Define output file generated by Open Watcom compiler, here obj file
wcc386 -q -bd -d0 -ecc -v -dNDEBUG -dBUILD_DLL -d_WIN32 src\dll_core.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=dll_core.obj
echo. ************     				 Dump des symboles exportes avec l option -v    				          *************
copy /y dll_core.def dll_core_two.def
type dll_core_two.def
echo. *****************           Edition des liens .ie. linkage de la DLL.        ***************
REM     Options used by linker of lcc compiler
REM 		system nt_dll     			Define output to be an Windows [NT] DLL 
REM 		initinstance terminstance   Mandatory to calle the entry point of DLL, here LibMain. It's a continued parameters after "system nnnn". 
REM 		run win 					Define subsystem to windows (either to generate GUI exe file or dll file)
REM 		EXPORT=filename.lbc			Instruct linker to add "alias" of function défined into dll, here file lbc is src\dll_core.lbc 
REM 		name xxxxxx 				Define output file generated by Open Watcom linker, here dll file.
REM 		file xxxxxx					Define input file of Open Watcom linker
REM 		option						Mandatory to add optionnal instructions to linker
REM 			implib=xxxxxx				Instruct linker to generate lib file in parallel of DLL 
REM 			quiet						Set to quiet mode
wlink system nt_dll initinstance terminstance run win EXPORT=src\dll_core.lbc LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386 option implib=dll_core.lib option quiet name dll_core.dll file dll_core.obj
REM 	Not mandatory here, wlink can generate lib file with option implib=dll_core.lib, but without another option impfile=dll_core.def on same line ???? 
REM wlib -q -n dll_core.lib +dll_core.dll
REM 	Options used by tool "wdump" of Open Watcom compiler
REM 		-i				Show list of exported symbols from a library/exe/obj/dll
echo. ************     				 Dump des sysboles exportes de la DLL dll_core.dll      				  *************
wdump -i dll_core.dll
echo. ************     Generation et lancement du premier programme de test de la DLL en mode implicite.      *************
wcc386 -q -bc -bt=nt -ecc -d0 -dNDEBUG -d_WIN32 src\testdll_implicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=testdll_implicit.obj
REM 	Options used by linker of Open Watcom compiler
REM 		-subsystem console 	Define subsystem to console, because generation of console application 
wlink option quiet system nt run console LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386 name testdll_implicit.exe file testdll_implicit.obj lib dll_core.lib
REM 	Run test program of DLL with implicit load
testdll_implicit.exe
echo. ************     Generation et lancement du deuxieme programme de test de la DLL en mode explicite.     ************
wcc386 -q -bc -bt=nt -d0 -ecc -dNDEBUG -d_WIN32 src\testdll_explicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=testdll_explicit.obj
wlink option quiet system nt run console LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386 name testdll_explicit.exe file testdll_explicit.obj lib dll_core.lib
REM 	Run test program of DLL with explicit load
testdll_explicit.exe					
 ) ELSE (
REM     Options used by Open Watcom compiler 32 bits
REM 		-q       					Set to quiet mode
REM 		-bd       					Set option to build DLL (used by compiler, only ?)
REM 		-l=nt_dll       			Set option to build DLL (used by linker)   (Needed here, "-bd" isn't enougth, MANDATORY)
REM										To be sure, suppress options "-q" and -"option quiet", and see the last message of linker : "creating a Windows NT dynamic link library" 
REM 		-d0 						No debugging information
REM 		-v 							Option to generate def file (like "option impfile=dll_core.def" ?!?!?)
REM 		-ecc						Set calling conv. to __cdecl (Mandatory, if you want test DLL with Python !!! If not, default is __watcall, and Python don't call "int" operations)
REM 		-dxxxxx	 					Define variable xxxxxx used by precompiler
REM 		-ixxxxxx					Define search path to include file
REM 		-fe=xxxxx 					Define output file generated by Open Watcom compiler, here dll file
REM 		-"xxxxxxxxxxxxxxxx" 		-"xxx" Define options transmit to linker : mandatory to add optionnal instructions to linker
REM 			LIBP pathlib1;pathlib2		Define librairies paths used by linker
REM 			EXPORT=filename.lbc			Instruct linker to add "alias" of function défined into dll, here file lbc is src\dll_core.lbc 
REM 			option impl=xxxxxx			Instruct linker to generate lib file in parallel of DLL
REM 			option quiet				Set to quiet mode
wcl386 -q -bd -l=nt_dll -d0 -v -ecc -dNDEBUG -dBUILD_DLL -d_WIN32 -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=dll_core.dll -"LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386" -"EXPORT=src\dll_core.lbc" -"option impl=dll_core.lib" -"option quiet" src\dll_core.c 
echo. ************     				 Dump des symboles exportes avec l option -v    				          *************
copy /y dll_core.def dll_core_one.def
type dll_core_one.def
REM 	Not mandatory here, wlink can generate lib file with option implib=dll_core.lib, but without another option impfile=dll_core.def on same line ???? bug ?
REM wlib -q -n dll_core.lib +dll_core.dll
REM 	Options used by tool "wdump" of Open Watcom compiler
REM 		-i				Show list of exported symbols from a library/exe/obj/dll
echo. ************     				 Dump des sysboles exportes de la DLL dll_core.dll      				  *************
wdump -i dll_core.dll
echo. ************     Generation et lancement du premier programme de test de la DLL en mode implicite.      *************
wcl386 -q -l=nt -d0 -bt=nt -ecc -dNDEBUG -d_WIN32 src\testdll_implicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=testdll_implicit.exe -"LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386" -"option quiet" -"lib dll_core.lib"
REM 	Run test program of DLL with implicit load
testdll_implicit.exe
echo. ************     Generation et lancement du deuxieme programme de test de la DLL en mode explicite.     ************
wcl386 -q -l=nt -d0 -ecc -dNDEBUG -d_WIN32 src\testdll_explicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=testdll_explicit.exe -"LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386" -"option quiet"
REM 	Run test program of DLL with explicit load
testdll_explicit.exe
)
echo. ****************               Lancement du script python 32 bits de test de la DLL.               ********************
%PYTHON32% version.py
REM 	Run test python script of DLL with explicit load
%PYTHON32% testdll_cdecl.py dll_core.dll 
REM 	Return in initial PATH
set PATH=%PATHINIT%
exit /B 

:complink64
echo. ******************          Compilation de la DLL en mode 64 bits        *******************
REM      Mandatory, add to PATH the binary directory of compiler OW 64 bits. You can adapt this directory at your personal software environment.
set PATH=C:\WATCOM\binnt64;%PATH%
set "PAR1=%~1"
if "%PAR1%" == "TWO" (
REM     Options used by Open Watcom compiler 64 bits
REM 		-q       					Set to quiet mode
REM 		-bd       					Set option to build DLL 
REM 		-d0 						No debugging information
REM 		-ecc						Set calling conv. to __cdecl (Mandatory, if you want test DLL with Python !!! If not, default is __watcall, and Python don't call "int" operations)
REM 		-v 							Option to generate def file (like "option impfile=dll_core.def" ?!?!? but without suppression of generation of lib file)
REM 		-dxxxxx	 					Define variable xxxxxx used by precompiler
REM 		-ixxxxxx					Define search path to include file
REM 		-fo=xxxxx 					Define output file generated by Open Watcom compiler, here obj file
wcc386 -q -bd -d0 -ecc -v -dNDEBUG -dBUILD_DLL -d_WIN32 src\dll_core.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=dll_core64.obj
echo. ************     				 Dump des symboles exportes avec l option -v    				          *************
copy /y dll_core.def dll_core64_two.def
type dll_core64_two.def
echo. *****************           Edition des liens .ie. linkage de la DLL.        ***************
REM     Options used by linker of lcc compiler
REM 		system nt_dll     			Define output to be an Windows [NT] DLL 
REM 		initinstance terminstance   Mandatory to calle the entry point of DLL, here LibMain. It's a continued parameters after "system nnnn". 
REM 		run win 					Define subsystem to windows (either to generate GUI exe file or dll file)
REM 		EXPORT=filename.lbc			Instruct linker to add "alias" of function défined into dll, here file lbc is src\dll_core64.lbc 
REM 		name xxxxxx 				Define output file generated by Open Watcom linker, here dll file.
REM 		file xxxxxx					Define input file of Open Watcom linker
REM 		option						Mandatory to add optionnal instructions to linker
REM 			implib=xxxxxx				Instruct linker to generate lib file in parallel of DLL 
REM 			quiet						Set to quiet mode
wlink system nt_dll initinstance terminstance run win EXPORT=src\dll_core64.lbc LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386 option implib=dll_core64.lib option quiet name dll_core64.dll file dll_core64.obj
REM 	Not mandatory here, wlink can generate lib file with option implib=dll_core64.lib, but without another option impfile=dll_core64.def on same line ???? 
REM wlib -q -n dll_core64.lib +dll_core64.dll
REM 	Options used by tool "wdump" of Open Watcom compiler
REM 		-i				Show list of exported symbols from a library/exe/obj/dll
echo. ************     				 Dump des symboles exportes de la DLL dll_core64.dll      				  *************
wdump -i dll_core64.dll
echo. ************     Generation et lancement du premier programme de test de la DLL en mode implicite.      *************
wcc386 -q -bc -bt=nt -d0 -ecc -dNDEBUG -d_WIN32 src\testdll_implicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=testdll_implicit64.obj
REM 	Options used by linker of Open Watcom compiler
REM 		-subsystem console 	Define subsystem to console, because generation of console application 
wlink option quiet system nt run console LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386 name testdll_implicit64.exe file testdll_implicit64.obj lib dll_core64.lib
REM 	Run test program of DLL with implicit load
testdll_implicit64.exe
echo. ************     Generation et lancement du deuxieme programme de test de la DLL en mode explicite.     ************
wcc386 -q -bc -bt=nt -d0 -ecc -dNDEBUG -d_WIN32 -d__OW64__ src\testdll_explicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fo=testdll_explicit64.obj
wlink option quiet system nt run console LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386 name testdll_explicit64.exe file testdll_explicit64.obj lib dll_core64.lib
REM 	Run test program of DLL with explicit load
testdll_explicit.exe					
 ) ELSE (
REM     Options used by Open Watcom compiler 32 bits
REM 		-q       					Set to quiet mode
REM 		-bd       					Set option to build DLL (used by compiler, only ?)
REM 		-l=nt_dll       			Set option to build DLL (used by linker)   (Needed here, "-bd" isn't enougth, MANDATORY)
REM										To be sure, suppress options "-q" and -"option quiet", and see the last message of linker : "creating a Windows NT dynamic link library" 
REM 		-d0 						No debugging information
REM 		-v 							Option to generate def file (like "option impfile=dll_core64.def" ?!?!?), the name of generated file is the same of name source code, extended to ".def"
REM 		-ecc						Set calling conv. to __cdecl (Mandatory, if you want test DLL with Python !!! If not, default is __watcall, and Python don't call "int" operations)
REM 		-dxxxxx	 					Define variable xxxxxx used by precompiler
REM 		-ixxxxxx					Define search path to include file
REM 		-fe=xxxxx 					Define output file generated by Open Watcom compiler, here dll file
REM 		-"xxxxxxxxxxxxxxxx" 		Define options transmit to linker : mandatory to add optionnal instructions to linker
REM 			LIBP pathlib1;pathlib2		Define librairies paths used by linker
REM 			EXPORT=filename.lbc			Instruct linker to add "alias" of function défined into dll, here file lbc is src\dll_core64.lbc 
REM 			option implib=xxxxxx		Instruct linker to generate lib file in parallel of DLL
REM 			option quiet				Set to quiet mode
wcl386 -q -bd -l=nt_dll -d0 -v -ecc -dNDEBUG -dBUILD_DLL -d_WIN32 -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=dll_core64.dll -"LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386" -"EXPORT=src\dll_core64.lbc" -"option implib=dll_core64.lib" -"option quiet" src\dll_core.c 
echo. ************     				 Dump des symboles exportes avec l option -v    				          *************
copy /y dll_core.def dll_core64_one.def
type dll_core64_one.def
REM 	Not mandatory here, wlink can generate lib file with option implib=dll_core64.lib, but without another option impfile=dll_core64.def on same line ???? Bug ?
REM wlib -q -n dll_core64.lib +dll_core64.dll
REM 	Options used by tool "wdump" of Open Watcom compiler
REM 		-i				Show list of exported symbols from a library/exe/obj/dll
echo. ************     				 Dump des symboles exportes de la DLL dll_core64.dll      				  *************
wdump -i dll_core64.dll
echo. ************     Generation et lancement du premier programme de test de la DLL en mode implicite.      *************
wcl386 -q -l=nt -d0 -bt=nt -ecc -dNDEBUG -d_WIN32 src\testdll_implicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=testdll_implicit64.exe -"LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386" -"option quiet" -"lib dll_core64.lib"
REM 	Run test program of DLL with implicit load
testdll_implicit64.exe
echo. ************     Generation et lancement du deuxieme programme de test de la DLL en mode explicite.     ************
wcl386 -q -l=nt -d0 -ecc -dNDEBUG -d_WIN32 -d__OW64__ src\testdll_explicit.c -i=C:\WATCOM\h\nt -i=C:\WATCOM\h -fe=testdll_explicit64.exe -"LIBP C:\WATCOM\lib386\nt;C:\WATCOM\lib386" -"option quiet"
REM 	Run test program of DLL with explicit load
testdll_explicit64.exe
)					
echo. *************   Lancement du script python 32 bits de test de la DLL (surprising! only 32 bits run)    ***************
%PYTHON32% version.py
REM 	Run test python script of DLL with explicit load
%PYTHON32% testdll_cdecl.py dll_core64.dll 
REM 	Return in initial PATH
set PATH=%PATHINIT%
exit /B 

:FIN
echo.        Fin de la generation de la DLL et des tests avec Open Watcom 32 bits ou 64 bits.
