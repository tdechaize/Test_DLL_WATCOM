//*******************           File : dllsamp.c (main core of dll)          *****************
#include <stdio.h> 
#include <windows.h> 

#if defined(__cplusplus) 
#define EXPORTED extern "C" __declspec( dllexport ) 
#else 
#define EXPORTED __declspec( dllexport ) 
#endif 

DWORD TlsIndex; /* Global Thread Local Storage index */ 

/* Error checking should be performed in following code */ 

BOOL APIENTRY LibMain( 	HANDLE hinstDLL, 
						DWORD  fdwReason, 
						LPVOID lpvReserved ) 
{ 
   switch( fdwReason ) { 
       case DLL_PROCESS_ATTACH: 
       /* do process initialization */ 

       /* create TLS index */ 
          TlsIndex = TlsAlloc();
		  printf( "Process attached to DLL.\n" ); 
          break; 

      case DLL_THREAD_ATTACH: 
      /* do thread initialization */ 

      /* allocate private storage for thread */ 
      /* and save pointer to it */ 
          TlsSetValue( TlsIndex, malloc(200) ); 
		  printf( "Thread attached to DLL.\n" ); 
          break; 

      case DLL_THREAD_DETACH: 
      /* do thread cleanup */ 

      /* get the TLS value and free associated memory */ 
		  printf( "Thread detached to DLL.\n" ); 
          free( TlsGetValue( TlsIndex ) ); 
          break; 

      case DLL_PROCESS_DETACH: 
      /* do process cleanup */ 

      /* free TLS index */ 
          TlsFree( TlsIndex ); 
		  printf( "Process detached to DLL.\n" ); 
          break; 
   } 
   return( 1 );                  /* indicate success */ 
/* returning 0 indicates initialization failure */ 
} 

EXPORTED void dll_entry_1( void ) 
{ 
     printf( "Hi from dll entry #1\n" ); 
} 

EXPORTED void dll_entry_2( void ) 
{ 
     printf( "Hi from dll entry #2\n" ); 
}
//*******************               End file : dllsamp.c                *****************

