//*******************       File : dlltest.c (program test of DLL with implicit load )       *****************
#include <stdio.h> 			//   Needed for printf function
#include <dos.h> 			//   Needed for sleep function
#include <process.h> 		//   Needed for all thread functions
#include <windows.h> 		// 	 Not needed !!! Stange, where are declared motifs to declare or call functions of DLL __declspec( dllexport ) or __declspec( dllimport ) ?

#if defined(__cplusplus) 
#define IMPORTED extern "C" __declspec( dllimport ) 
#else 
#define IMPORTED __declspec( dllimport ) 
#endif 

IMPORTED void dll_entry_1( void ); 
IMPORTED void dll_entry_2( void ); 

#define STACK_SIZE 8192 

static void thread( void *arglist ) 
{ 
  printf( "Hi from thread\n" );
  sleep(1000);
  _endthread(); 
} 

int main( void ) 
{ 
   unsigned long tid; 

   dll_entry_1(); 
   tid = _beginthread( thread, STACK_SIZE, NULL ); 
   dll_entry_2(); 
   return( 0 ); 
} 
//*******************       			End file : dlltest.c       					*****************
