// viHelper.h: interface for the CviFileInfo class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIHELPER_H__9FF5F541_F695_11D4_B1DF_00508B8F0099__INCLUDED_)
#define AFX_VIHLPER_H__9FF5F541_F695_11D4_B1DF_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "..\SharedInclude\viString.h"

CviString & GetErrorText(DWORD dwErrorNr);
BOOL        FileExists( LPCTSTR szFullFileName );
BOOL        FileOlder( LPCTSTR szFullFileName, LPFILETIME lpCompareTime );
CviString & viGetTempFileName( LPCTSTR strDir, LPCTSTR strPrefix, LPCTSTR strExtension );
void        DoEvents( void );


// Macro enables handling of multiple deletes for one object
#ifndef UFM_DELETE
 #define UFM_DELETE(a) if (a) delete(a); a = NULL;
#endif

// Macro enables handling of multiple deletes for one LPCTSTR
#ifndef UFM_DELETE_LPCTSTR
 #define UFM_DELETE_LPCTSTR(a) if (a) delete((LPTSTR)a); a = NULL;
#endif

// Macro enables handling of multiple frees for one pointer
#ifndef UFM_FREE
 #define UFM_FREE(a) if (a) free((a)); a = NULL;
#endif

// Macro enables handling of multiple frees for one LPCTSTR
#ifndef UFM_FREE_LPCTSTR
 #define UFM_FREE_LPCTSTR(a) if (a) free((LPTSTR)(a)); a = NULL;
#endif

// SEH-Macros without stack-rewinding (--> goto)
#ifndef UFM_TRY
 #define UFM_TRY
#endif

#ifndef UFM_LEAVE
 #define UFM_LEAVE goto __UFM_FINALLY_P
#endif

#ifndef UFM_FINALLY
 #define UFM_FINALLY __UFM_FINALLY_P:
#endif

#ifdef _DEBUG
	#ifndef VITRACE0
		#define VITRACE(a) \
		static CviString g_TraceString; g_TraceString=a; OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif

	#ifndef VITRACE1
		#define VITRACE1(a,b) \
		static CviString g_TraceString; g_TraceString.Format(a,b); OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif

	#ifndef VITRACE2
		#define VITRACE2(a,b,c) \
		static CviString g_TraceString; g_TraceString.Format(a,b,c); OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif

	#ifndef VITRACE3
		#define VITRACE3(a,b,c,d) \
		static CviString g_TraceString; g_TraceString.Format(a,b,c,d); OutputDebugString( g_TraceString.operator LPCTSTR() );
	#endif
#else
	#ifndef VITRACE0
		#define VITRACE(a)
	#endif

	#ifndef VITRACE1
		#define VITRACE1(a,b) 
	#endif

	#ifndef VITRACE2
		#define VITRACE2(a,b,c)
	#endif

	#ifndef VITRACE3
		#define VITRACE3(a,b,c,d)
	#endif

#endif


#endif // !defined(AFX_VIHLPER_H__9FF5F541_F695_11D4_B1DF_00508B8F0099__INCLUDED_)