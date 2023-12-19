//*********************    File : dll_share.h (include file shared beetween core DLL and program test DLL)    *****************
#ifndef HEADER_SHARED_DLL
#define HEADER_SHARED_DLL

/* Test Windows platform */

#if defined(__NT__) || defined(_WIN32) || defined(_Windows) // __NT__ with OpenWatcom, _WIN32 with GCC, MSVC, clang, Pelles C, lcc (?) _Windows with Borland C/C++ defined Windows Platforms

  /* You should define BUILD_DLL *only* when building the DLL. */
  
  #ifdef BUILD_DLL
    #define FUNCAPI  __declspec(dllexport)
  #else
    #define FUNCAPI  __declspec(dllimport)
  #endif

  /* Define calling convention in one place, for convenience. */
  #if defined(__LCC__) // || defined(__WATCOMC__)
    #define FUNCCALL  __stdcall
  #elif defined (__BORLANDC__) || defined(__POCC__)
    #define FUNCCALL  __stdcall
  #else	
    #define FUNCCALL  __cdecl
  # endif


#elif defined(__linux__) || defined(__unix__) || defined(__APPLE__) || defined(__FreeBSD__)

	#if defined(BUILD_DLL) && defined(HAS_GCC_VISIBILITY)
	#   define FUNCAPI  _attribute_  _((visibility("default")))
	#endif

#else /* __NT__ or _WIN32 or _Windows or __linux__ or __unix__ or __APPLE__ (MAC OS) or __FreeBSD__ not defined. */

  /* Define with no value on non-Windows OSes. */
  #define FUNCAPI
  #define FUNCCALL

#endif

extern FUNCAPI int Hello(void);
extern FUNCAPI int Addint(int i1, int i2);
extern FUNCAPI int Subint(int i1, int i2);
extern FUNCAPI int Multint(int i1, int i2);
extern FUNCAPI int Divint(int i1, int i2);
extern FUNCAPI int Squarint(int i);
extern FUNCAPI double Adddbl(double i1, double i2);
extern FUNCAPI double Subdbl(double i1, double i2);
extern FUNCAPI double Multdbl(double i1, double i2);
extern FUNCAPI double Divdbl(double i1, double i2);
extern FUNCAPI double Squardbl(double i2);

#endif // header guard
//*********************    					End file : dll_share.h     							*****************
